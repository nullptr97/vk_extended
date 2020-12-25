//
//  NewsfeedViewController.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 21.11.2020.
//

import UIKit
import IGListKit
import DRPLoadingSpinner

class NewsfeedViewController: BaseViewController, NewsfeedViewProtocol {
    var presenter: NewsfeedPresenterProtocol?

    let mainCollection = UICollectionView(frame: .zero, collectionViewLayout: ListCollectionViewLayout(stickyHeaders: false, topContentInset: 0, stretchToEdge: false))
    lazy var adapter: ListAdapter = {
        let listAdapter = ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 1)
        listAdapter.collectionView = mainCollection
        listAdapter.dataSource = self
        return listAdapter
    }()
    private var feedViewModel: FeedViewModel = FeedViewModel.init(cells: [], footerTitle: nil)
    var data = [ListDiffable]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareTabItem()
        setupBackground()
        
        NewsfeedRouter.initModule(self)
        presenter?.start(request: .getNewsfeed())
        
        prepareCollection()
        setupCollection()
    }
    
    func displayData(viewModel: Newsfeed.Model.ViewModel.ViewModelData) {
        switch viewModel {
        case .displayNewsfeed(let feedViewModel):
            self.feedViewModel = feedViewModel
            data = feedViewModel.cells

            adapter.reloadData { [weak self] (updated) in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.mainCollection.reloadData()
                    self.refreshControl.endRefreshing()
                }
            }
        case .displayFooterLoader:
            self.refreshControl.beginRefreshing()
        case .displayFooterError(message: let messageError):
            mainCollection.reloadData()
        default:
            break
        }
    }
    
    // Подготовка коллекции
    func prepareCollection() {
        view.addSubview(mainCollection)
        mainCollection.autoPinEdge(.top, to: .top, of: view, withOffset: 8)
        mainCollection.autoPinEdge(.bottom, to: .bottom, of: view)
        mainCollection.autoPinEdge(.trailing, to: .trailing, of: view)
        mainCollection.autoPinEdge(.leading, to: .leading, of: view)
        mainCollection.backgroundColor = .getThemeableColor(fromNormalColor: .white)
        adapter.collectionViewDelegate = self
    }
    
    // Настройка коллекции
    func setupCollection() {
        mainCollection.keyboardDismissMode = .onDrag
        mainCollection.allowsMultipleSelection = true
        refreshControl.add(to: mainCollection) { [weak self] in
            guard let self = self else { return }
            self.reloadNews()
        }
    }
    
    // Подготовка элемента таббара
    fileprivate func prepareTabItem() {
        tabItem.title = "Новости"
        tabItem.setTabItemColor(.adaptableBlack, for: .selected)
        tabItem.setTabItemColor(.adaptableDarkGrayVK, for: .normal)
        tabItem.titleLabel?.font = GoogleSansFont.bold(with: 17)
        tabItem.titleLabel?.adjustsFontSizeToFitWidth = true
        tabItem.titleLabel?.allowsDefaultTighteningForTruncation = true
    }
    
    // При обновлении страницы
    @objc func reloadNews() {
        presenter?.start(request: .getNewsfeed())
    }
    
    // При подгрузке дополнительных новостей
    @objc func getNext() {
        presenter?.start(request: .getNextBatch)
    }
}
extension NewsfeedViewController: UICollectionViewDelegate { }
extension NewsfeedViewController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return data
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return NewsSectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}
