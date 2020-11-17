//
//  RowLayout.swift
//  VKExt
//
//  Created by programmist_NA on 11.07.2020.
//

import Foundation
import UIKit

protocol RowLayoutDelegate: class {
    func collectionView(_ collectionView: UICollectionView, photoAtIndexPath indexPath: IndexPath) -> CGSize
}

class RowLayout: UICollectionViewLayout {
    
    weak var delegate: RowLayoutDelegate!
    
    static var numbersOfRows = 2
    fileprivate var cellPadding: CGFloat = 2
    
    fileprivate var cache = [UICollectionViewLayoutAttributes]()
    
    fileprivate var contentWidth: CGFloat = 0
    
    // константа
    fileprivate var contentHeight: CGFloat {
        
        guard let collectionView = collectionView else { return 0 }

        let insets =  collectionView.contentInset
        return collectionView.bounds.height - (insets.left + insets.right)
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {
        contentWidth = 0
        cache = []
        guard cache.isEmpty == true, let collectionView = collectionView else { return }
        
        var photos = [CGSize]()
        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            let photoSize = delegate.collectionView(collectionView, photoAtIndexPath: indexPath)
            photos.append(photoSize)
        }
                
        guard var rowHeight = RowLayout.getCollectionHeight(photos: photos) else { return }
        
        rowHeight = rowHeight / CGFloat(RowLayout.numbersOfRows)
        
        let photosRatios = photos.map { $0.height / $0.width }
        
        var yOffset = [CGFloat]()
        for row in 0 ..< RowLayout.numbersOfRows {
            yOffset.append(CGFloat(row) * rowHeight)
        }
        
        var xOffset = [CGFloat](repeating: 0, count: RowLayout.numbersOfRows)
        
        var row = 0
        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            
            let ratio = photosRatios[indexPath.row]
            let width = (rowHeight / ratio)
            let frame = CGRect(x: xOffset[row], y: yOffset[row], width: width, height: rowHeight)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            
            let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attribute.frame = insetFrame
            cache.append(attribute)
            
            contentWidth = max(contentWidth, frame.maxX)
            xOffset[row] = xOffset[row] + width
            row = row < (RowLayout.numbersOfRows - 1) ? (row + 1) : 0
        }
        
    }
    
    static func getCollectionHeight(photos: [CGSize]) -> CGFloat? {
        let newScreenWidth = screenWidth - 32
        switch photos.count {
        case 1:
            return (newScreenWidth / 3) * 2
        case 2:
            return (newScreenWidth / 5) * 2 + (newScreenWidth / 5) * 2
        case 3:
            return (newScreenWidth / 9) * 3
        case 4:
            return (newScreenWidth / 20) * 7
        case 5:
            return (newScreenWidth / 12) * 8 + (newScreenWidth / 20) * 7
        case 6:
            return (newScreenWidth / 9) * 4 + (newScreenWidth / 9) * 2
        case 7:
            return (newScreenWidth / 9) * 3 + (newScreenWidth / 20) * 7
        case 8:
            return (newScreenWidth / 3) * 1 + (newScreenWidth / 3) * 1
        case 9:
            return (newScreenWidth / 9) * 3 + (newScreenWidth / 9) * 3 + (newScreenWidth / 9) * 3
        case 10:
            return (newScreenWidth / 0.215) + (newScreenWidth / 9) * 3 + (newScreenWidth / 0.215) + (newScreenWidth / 9) * 3
        default:
            return nil
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for attatibute in cache {
            if attatibute.frame.intersects(rect) {
                visibleLayoutAttributes.append(attatibute)
            }
        }
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.row]
    }
}

class MessageLayout: UICollectionViewLayout {
    
    weak var delegate: RowLayoutDelegate!
    
    fileprivate var cellPadding: CGFloat = 2
    
    fileprivate var cache = [UICollectionViewLayoutAttributes]()
    
    fileprivate var contentWidth: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        return collectionView.bounds.width
    }
    
    // константа
    fileprivate var contentHeight: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        return collectionView.bounds.height
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {
        cache = []
        guard cache.isEmpty == true, let collectionView = collectionView else { return }
        
        var messageText = [CGSize]()
        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            let photoSize = delegate.collectionView(collectionView, photoAtIndexPath: indexPath)
            messageText.append(photoSize)
        }
        
        
        guard let rowHeight = RowLayout.getCollectionHeight(photos: messageText) else { return }
        
        let photosRatios = messageText.map { $0.height / $0.width }
        
        var yOffset = [CGFloat]()
        for row in 0 ..< RowLayout.numbersOfRows {
            yOffset.append(CGFloat(row) * rowHeight)
        }
        
        var xOffset = [CGFloat](repeating: 0, count: RowLayout.numbersOfRows)
        
        var row = 0
        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            
            let ratio = photosRatios[indexPath.row]
            let width = (rowHeight / ratio)
            let frame = CGRect(x: xOffset[row], y: yOffset[row], width: width, height: rowHeight)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            
            let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attribute.frame = insetFrame
            cache.append(attribute)

            xOffset[row] = xOffset[row] + width
            row = row < (RowLayout.numbersOfRows - 1) ? (row + 1) : 0
        }
    }
    
    static func rowHeightCounter(superviewWidth: CGFloat, photosArray: [CGSize]) -> CGFloat? {
        if photosArray.count == 1 {
            return screenWidth
        } else if photosArray.count == 2 {
            return photosArray[0].height * 2
        } else if photosArray.count == 3 {
            return photosArray[0].height
        } else if photosArray.count == 4 {
            return photosArray[0].height + photosArray[1].height
        } else if photosArray.count == 5 {
            return photosArray[0].height + photosArray[1].height + photosArray[2].height
        } else if photosArray.count == 6 {
            return photosArray[0].height + photosArray[5].height
        } else if photosArray.count == 7 {
            return photosArray[0].height + photosArray[1].height + photosArray[4].height
        } else if photosArray.count == 8 {
            return photosArray[0].height + photosArray[1].height + photosArray[2].height + photosArray[5].height
        } else if photosArray.count == 9 {
            return photosArray[0].height + photosArray[3].height + photosArray[8].height
        } else {
            return photosArray[0].height + photosArray[1].height + photosArray[4].height + photosArray[7].height
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for attatibute in cache {
            if attatibute.frame.intersects(rect) {
                visibleLayoutAttributes.append(attatibute)
            }
        }
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.row]
    }
}
