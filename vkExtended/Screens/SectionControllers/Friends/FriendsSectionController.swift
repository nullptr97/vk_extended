//
//  FriendsSectionController.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 09.12.2020.
//

import Foundation
import IGListKit

class FriendsSectionController: ListBindingSectionController<FriendViewModel>, ListBindingSectionControllerDataSource {
    var results = [ListDiffable]()

    override init() {
        super.init()
        dataSource = self
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, viewModelsFor object: Any) -> [ListDiffable] {
        guard let object = object as? FriendViewModel else { fatalError() }
        results.append(ProfileFriendsViewModel(cell: object.cell, count: object.count))
        results.append(NewsfeedDividerViewModel())
        return results
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, cellForViewModel viewModel: Any, at index: Int) -> UICollectionViewCell & ListBindable {
        let identifier: String
        switch viewModel {
        case is ProfileFriendsViewModel:
            identifier = "FriendsCollectionViewCell"
            let cell = collectionContext?.dequeueReusableCell(of: FriendsCollectionViewCell.self, for: sectionController, at: index) as! FriendsCollectionViewCell
            return cell
        case is NewsfeedDividerViewModel:
            identifier = "DividerCollectionViewCell"
            let cell = collectionContext?.dequeueReusableCell(withNibName: identifier, bundle: nil, for: sectionController, at: index) as! DividerCollectionViewCell
            return cell
        default:
            fatalError()
        }
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, sizeForViewModel viewModel: Any, at index: Int) -> CGSize {
        guard let collectionContext = collectionContext else { fatalError() }
        let height: CGFloat
        var width: CGFloat
        switch viewModel {
        case is ProfileFriendsViewModel:
            width = collectionContext.containerSize.width
            height = 144
        case is NewsfeedDividerViewModel:
            height = 0.5
            width = collectionContext.containerSize.width - 24
        default:
            width = collectionContext.containerSize.width
            height = 0
        }
        return .custom(width, height)
    }
}
