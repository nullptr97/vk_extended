//
//  WallTableViewCell.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 23.11.2020.
//

import UIKit
import IGListKit

class WallTableViewCell: UITableViewCell {
    
    let mainCollection = UICollectionView(frame: .zero, collectionViewLayout: ListCollectionViewLayout(stickyHeaders: false, topContentInset: 0, stretchToEdge: false))
    lazy var adapter: ListAdapter = { return ListAdapter(updater: ListAdapterUpdater(), viewController: parentViewController) }()
    private var wallViewModel: FeedViewModel = FeedViewModel.init(cells: [], footerTitle: nil)
    var data = [ListDiffable]()

    override func awakeFromNib() {
        super.awakeFromNib()
        prepareCollection()
        setupCollection()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // Инициализация ячейки
    func initCell(from viewModel: FeedViewModel) {
        wallViewModel = viewModel
        data = wallViewModel.cells
        
        prepareCollection()
        setupCollection()
        
        adapter.dataSource = self
        adapter.collectionView = mainCollection
    }
    
    // Подготовка коллекции
    func prepareCollection() {
        contentView.addSubview(mainCollection)
        mainCollection.autoPinEdgesToSuperviewEdges()
        mainCollection.backgroundColor = .getThemeableColor(fromNormalColor: .white)
    }
    
    // Настройка коллекции
    func setupCollection() {
        mainCollection.isScrollEnabled = false
        mainCollection.keyboardDismissMode = .onDrag
        mainCollection.allowsMultipleSelection = true
    }
}
extension WallTableViewCell: ListAdapterDataSource {
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
