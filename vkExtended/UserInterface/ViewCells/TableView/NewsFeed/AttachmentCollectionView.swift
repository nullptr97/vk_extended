//
//  AttachmentCollectionView.swift
//  VKExt
//
//  Created by programmist_NA on 11.07.2020.
//

import Foundation
import UIKit
import Material
import IBPCollectionViewCompositionalLayout

class GalleryCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var photos = [AttachmentCellViewModel]()
    
    init() {
        super.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        delegate = self
        dataSource = self
        
        backgroundColor = .adaptableWhite
        isScrollEnabled = false
        
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        
        register(GalleryCollectionViewCell.self, forCellWithReuseIdentifier: GalleryCollectionViewCell.reuseId)
    }
    
    func generateLayout() -> UICollectionViewLayout {
        // Full
        let fullPhotoItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)), supplementaryItems: [])
        fullPhotoItem.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

        // Main with pair
        let mainItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1/3)))
        mainItem.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        
        let pairItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.5)))
        pairItem.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        
        let mainVerticalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/2), heightDimension: .fractionalHeight(1.0)), subitems: [fullPhotoItem, fullPhotoItem])
        mainVerticalGroup.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        
        // Triplet
        let tripletItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalHeight(1.0)))
        tripletItem.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        
        let tripletGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(3/9)), subitems: [tripletItem, tripletItem, tripletItem])
        
        let mainItem2 = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(8/12)))

        let mainHorizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/2), heightDimension: .fractionalHeight(1.0)), subitems: [fullPhotoItem, fullPhotoItem])
        mainHorizontalGroup.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        
        let trailing2Group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1/20)), subitem: mainItem, count: 4)
        
        let trailing5Group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1/3)), subitem: mainItem, count: 4)
        
        let trailing3Group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(4/21)), subitem: mainItem, count: 2)
        trailing3Group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: -8, trailing: 0)
        
        let trailing4Group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.215)), subitem: mainItem, count: 2)
        trailing4Group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0)
        
        let nestedGroup: NSCollectionLayoutGroup
        let simpleCollectionLayoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        
        switch photos.count {
        case 1:
            nestedGroup = NSCollectionLayoutGroup.vertical(layoutSize: simpleCollectionLayoutSize, subitems: [fullPhotoItem])
        case 2:
            nestedGroup = NSCollectionLayoutGroup.horizontal(layoutSize: simpleCollectionLayoutSize, subitems: [mainVerticalGroup])
        case 3:
            nestedGroup = NSCollectionLayoutGroup.vertical(layoutSize: simpleCollectionLayoutSize, subitems: [tripletGroup])
        case 4:
            nestedGroup = NSCollectionLayoutGroup.vertical(layoutSize: simpleCollectionLayoutSize, subitems: [trailing2Group])
        case 5:
            nestedGroup = NSCollectionLayoutGroup.vertical(layoutSize: simpleCollectionLayoutSize, subitems: [mainItem2, trailing2Group])
        case 6:
            nestedGroup = NSCollectionLayoutGroup.vertical(layoutSize: simpleCollectionLayoutSize, subitems: [tripletGroup, tripletGroup])
        case 7:
            nestedGroup = NSCollectionLayoutGroup.vertical(layoutSize: simpleCollectionLayoutSize, subitems: [tripletGroup, trailing2Group])
        case 8:
            nestedGroup = NSCollectionLayoutGroup.vertical(layoutSize: simpleCollectionLayoutSize, subitems: [trailing5Group, trailing5Group])
        case 9:
            nestedGroup = NSCollectionLayoutGroup.vertical(layoutSize: simpleCollectionLayoutSize, subitems: [tripletGroup, tripletGroup, tripletGroup])
        default:
            nestedGroup = NSCollectionLayoutGroup.vertical(layoutSize: simpleCollectionLayoutSize, subitems: [trailing4Group, tripletGroup, trailing4Group, tripletGroup])
        }

        let section = NSCollectionLayoutSection(group: nestedGroup)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    func set(photos: [AttachmentCellViewModel]) {
        self.photos = photos
        contentOffset = CGPoint.zero
        reloadData()
        collectionViewLayout = generateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(withReuseIdentifier: GalleryCollectionViewCell.reuseId, for: indexPath) as! GalleryCollectionViewCell
        cell.set(imageUrl: photos[indexPath.item].photoUrlString)
        return cell
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension GalleryCollectionView: RowLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, photoAtIndexPath indexPath: IndexPath) -> CGSize {
        let width = photos[indexPath.row].width / 2
        let height = photos[indexPath.row].height / 2
        return CGSize(width: width, height: height)
    }
}
