//
//  SuggestionsViewController.swift
//  VKExt
//
//  Created programmist_NA on 12.07.2020.
//  Copyright © 2020 ExtendedTeam. All rights reserved.
//
import UIKit
import IGListKit
import Material
import DRPLoadingSpinner

class SuggestionsViewController: UIViewController, SuggestionsViewProtocol {
	var presenter: SuggestionsPresenterProtocol?
    private var tabsViewController: TabsController?

    let pagesCollection = CollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private var topics = [Topic]()
    private var currentIndex: Int = 0

	override func viewDidLoad() {
        super.viewDidLoad()
        prepareTabItem()
        setupBackground()

        SuggestionsRouter.createModule(self)
        presenter?.start(request: .getTopics)
    }

    // При обновлении страницы
    @objc func reloadNews() {
        presenter?.start(request: .getSuggestions)
    }
    
    func displayData(viewModel: Newsfeed.Model.ViewModel.ViewModelData) {
        switch viewModel {
        case .displayTopics(topics: let topics):
            self.topics = topics
            
            tabsViewController = TabsController(viewControllers: topics.compactMap { TopicNewsfeedViewController(with: $0) })
            tabsViewController?.view.backgroundColor = .clear
            tabsViewController?.view.frame = CGRect(x: 0, y: 0,width: view.frame.width, height: view.frame.height)
            addChild(tabsViewController!)
            view.addSubview(tabsViewController!.view)
            tabsViewController?.view.frame = CGRect(origin: CGPoint(x: 0, y: 48), size: .custom(screenWidth, screenHeight - 48))
            tabsViewController?.didMove(toParent: self)
            tabsViewController?.delegate = self
            
            view.addSubview(pagesCollection)
            pagesCollection.backgroundColor = .getThemeableColor(fromNormalColor: .white)
            pagesCollection.autoPinEdge(toSuperviewSafeArea: .top, withInset: 8)
            pagesCollection.autoPinEdge(.leading, to: .leading, of: view)
            pagesCollection.autoPinEdge(.trailing, to: .trailing, of: view)
            pagesCollection.autoSetDimension(.height, toSize: 48)
            pagesCollection.showsHorizontalScrollIndicator = false
            
            let layout = pagesCollection.collectionViewLayout as! UICollectionViewFlowLayout
            layout.scrollDirection = .horizontal
            
            pagesCollection.delegate = self
            pagesCollection.dataSource = self
            pagesCollection.register(nib: UINib(nibName: "TopicPageCollectionViewCell", bundle: nil), forCellWithClass: TopicPageCollectionViewCell.self)
        default:
            break
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.y > scrollView.contentSize.height / 1.1 {
            presenter?.start(request: Newsfeed.Model.Request.RequestType.getNextBatch)
        }
    }

    // Подготовка элемента таббара
    fileprivate func prepareTabItem() {
        tabItem.title = "Интересное"
        tabItem.setTabItemColor(.adaptableBlack, for: .selected)
        tabItem.setTabItemColor(.adaptableDarkGrayVK, for: .normal)
        tabItem.titleLabel?.font = GoogleSansFont.bold(with: 17)
    }
}
extension SuggestionsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return topics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: TopicPageCollectionViewCell.self, for: indexPath)
        if indexPath.item == 0 {
            cell.setSelected()
        }
        cell.topicNameLabel.text = topics[indexPath.item].name
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? TopicPageCollectionViewCell else { return }
        if indexPath.item == tabsViewController?.selectedIndex {
            cell.setSelected()
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        } else {
            cell.setUnselected()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .custom(topics[indexPath.item].name.width(with: 40, font: GoogleSansFont.semibold(with: 15)) + 32, 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .horizontal(8)
    }
}
extension SuggestionsViewController: TopicSelectorDelegate {
    func selectTopic(for cell: TopicPageCollectionViewCell) {
        guard let index = pagesCollection.indexPath(for: cell)?.item else { return }
        tabsViewController?.select(at: index)
        configurePageCell(at: index)
    }
}
extension SuggestionsViewController: TabsControllerDelegate {
    func tabsController(tabsController: TabsController, didSelect viewController: UIViewController) {
        configurePageCell(at: tabsController.selectedIndex)
    }

    func configurePageCell(at index: Int) {
        let cells = topics.enumerated().compactMap { pagesCollection.cellForItem(at: IndexPath(item: $0.offset, section: 0)) as? TopicPageCollectionViewCell }
        _ = cells.compactMap { cell in
            guard let indexPath = self.pagesCollection.indexPath(for: cell) else { return }
            if indexPath.item == index {
                cell.setSelected()
                self.pagesCollection.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            } else {
                cell.setUnselected()
            }
        }
    }
}
