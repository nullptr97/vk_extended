//
//  NewsTextSectionController.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 21.11.2020.
//

import UIKit
import IGListKit

class NewsTextSectionController: ListSectionController {
    var currentNewsModel: FeedCellViewModel?
    
    override func didUpdate(to object: Any) {
        guard let newsModel = object as? FeedCellViewModel else { return }
        currentNewsModel = newsModel
    }
    
    override func numberOfItems() -> Int {
        return 1
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let newsModel = currentNewsModel else { return UICollectionViewCell() }
        guard let ctx = collectionContext else { return UICollectionViewCell() }
        guard let newsText = newsModel.text else { return UICollectionViewCell() }
        
        let nibName = String(describing: NewsfeedTextCollectionViewCell.self)
        let cell = ctx.dequeueReusableCell(withNibName: nibName, bundle: nil, for: self, at: index) as! NewsfeedTextCollectionViewCell
        
        cell.newsTextLabel.text = newsText
        
        return cell
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        let width = collectionContext?.containerSize.width ?? 0
        return .custom(width, currentNewsModel?.sizes.postLabelFrame.size.height ?? 0)
    }
}
