//
//  PhotosSectionController.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 25.11.2020.
//

import Foundation
import IGListKit

class PhotosSectionController: ListBindingSectionController<PhotoViewModel>, ListBindingSectionControllerDataSource {
    var results = [ListDiffable]()

    override init() {
        super.init()
        dataSource = self
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, viewModelsFor object: Any) -> [ListDiffable] {
        guard let object = object as? PhotoViewModel else { fatalError() }
        results.append(ProfilePhotosViewModel(cell: object.cell, count: object.count))
        results.append(NewsfeedDividerViewModel())
        return results
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, cellForViewModel viewModel: Any, at index: Int) -> UICollectionViewCell & ListBindable {
        let identifier: String
        switch viewModel {
        case is ProfilePhotosViewModel:
            identifier = "PhotosCollectionViewCell"
            let cell = collectionContext?.dequeueReusableCell(withNibName: identifier, bundle: nil, for: sectionController, at: index) as! PhotosCollectionViewCell
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
        var height: CGFloat
        var width: CGFloat
        switch viewModel {
        case is ProfilePhotosViewModel:
            width = collectionContext.containerSize.width
            height = UIScreen.main.bounds.width / 4 + 40
        case is NewsfeedDividerViewModel:
            width = collectionContext.containerSize.width - 24
            height = 0.5
        default:
            width = collectionContext.containerSize.width
            height = 0
        }
        return .custom(width, height)
    }
}
