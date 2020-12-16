//
//  NewsfeedViewController.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 21.11.2020.
//

import UIKit
import IGListKit
import DRPLoadingSpinner

class NewsfeedViewController: UIViewController, NewsfeedViewProtocol {
    var presenter: NewsfeedPresenterProtocol?

    let mainCollection = UICollectionView(frame: .zero, collectionViewLayout: ListCollectionViewLayout(stickyHeaders: false, topContentInset: 0, stretchToEdge: false))
    private lazy var refreshControl = DRPRefreshControl()
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
                    self.mainCollection.refreshHeader?.success(withDelay: 1)
                    self.mainCollection.refreshFooter?.success(withDelay: 1)
                }
            }
        case .displayFooterLoader:
            mainCollection.refreshHeader?.start()
        case .displayFooterError(message: let messageError):
            mainCollection.refreshFooter?.error(messageError)
            mainCollection.refreshHeader?.error(messageError)
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
        mainCollection.contentInset.bottom = 0
    }
    
    // Настройка коллекции
    func setupCollection() {
        mainCollection.keyboardDismissMode = .onDrag
        mainCollection.allowsMultipleSelection = true
        
        mainCollection.addRefreshHeader { [weak self] (footer) in
            if self == nil {
                return
            }

            self?.reloadNews()
        }
        
        mainCollection.addRefreshFooter { [weak self] (footer) in
            if self == nil {
                return
            }

            self?.getNext()
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
extension DRPLoadingSpinner: AnyRefreshContent {
    public func setProgress(_ progress: CGFloat) {
        
    }
    
    public func start() {
        startAnimating()
    }
    
    public func stop() {
        stopAnimating()
    }
}
