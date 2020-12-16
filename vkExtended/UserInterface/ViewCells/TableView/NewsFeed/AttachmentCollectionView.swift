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
        
        backgroundColor = .getThemeableColor(fromNormalColor: .white)
        isScrollEnabled = false
        
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        
        register(GalleryCollectionViewCell.self, forCellWithReuseIdentifier:  GalleryCollectionViewCell.reuseId)
    }
    
    func generateLayout() -> UICollectionViewLayout {
        // Full
        let fullPhotoItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)), supplementaryItems: [])
        fullPhotoItem.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)

        // Main with pair
        let mainItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1/3)))
        mainItem.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)
        
        let pairItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.5)))
        pairItem.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)
        
        let mainVerticalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/2), heightDimension: .fractionalHeight(1.0)), subitems: [fullPhotoItem, fullPhotoItem])
        mainVerticalGroup.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)
        
        // Triplet
        let tripletItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalHeight(1.0)))
        tripletItem.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)
        
        let tripletGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(3/9)), subitems: [tripletItem, tripletItem, tripletItem])
        
        let mainItem2 = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(8/12)))

        let mainHorizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/2), heightDimension: .fractionalHeight(1.0)), subitems: [fullPhotoItem, fullPhotoItem])
        mainHorizontalGroup.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)
        
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

class NewsAttachmentsCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var photos = [AttachmentCellViewModel]()

    init() {
        let layout = UICollectionViewFlowLayout()
        super.init(frame: .zero, collectionViewLayout: layout)
        delegate = self
        dataSource = self
        
        backgroundColor = .getThemeableColor(fromNormalColor: .white)
        isScrollEnabled = true
        bounces = false
        
        layout.scrollDirection = .horizontal
        
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        
        isPagingEnabled = true
        
        register(GalleryCollectionViewCell.self, forCellWithReuseIdentifier:  GalleryCollectionViewCell.reuseId)
    }
    
    func set(photos: [AttachmentCellViewModel]) {
        self.photos = photos
        contentOffset = CGPoint.zero
        reloadData()
        let parentView = superview as! NewsfeedPhotoAttachmentsCollectionViewCell
        parentView.counterLabel.text = "1 из \(photos.count)"
        parentView.counterLabel.sizeToFit()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(withReuseIdentifier: GalleryCollectionViewCell.reuseId, for: indexPath) as! GalleryCollectionViewCell
        cell.set(imageUrl: photos[indexPath.item].photoUrlString)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .identity(collectionView.bounds.width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let parentView = collectionView.superview as? NewsfeedPhotoAttachmentsCollectionViewCell else { return }
        guard let attachmentCell = cell as? GalleryCollectionViewCell else { return }
        parentView.counterLabel.text = "\(indexPath.item + 1) из \(photos.count)"
        parentView.counterLabel.sizeToFit()
        parentView.counterView.backgroundColor = attachmentCell.photoImageView.image?.averageColor?.isLight ?? false ? UIColor.getThemeableColor(fromNormalColor: .black).withAlphaComponent(0.5) : UIColor.getThemeableColor(fromNormalColor: .white).withAlphaComponent(0.5)
        parentView.counterLabel.textColor = attachmentCell.photoImageView.image?.averageColor?.isLight ?? false ? .getThemeableColor(fromNormalColor: .white) : .getThemeableColor(fromNormalColor: .black)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Scrollview.tag will equal to your collection view's tag
    // Use page to update page control or whatever
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let page = Int(floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1)

        guard let parentView = superview as? NewsfeedPhotoAttachmentsCollectionViewCell else { return }
        guard let attachmentCell = cellForItem(at: IndexPath(item: page, section: 0)) as? GalleryCollectionViewCell else { return }

        parentView.counterLabel.text = "\(page + 1) из \(photos.count)"
        parentView.counterLabel.sizeToFit()
        parentView.counterView.backgroundColor = attachmentCell.photoImageView.image?.averageColor?.isLight ?? false ? UIColor.getThemeableColor(fromNormalColor: .black).withAlphaComponent(0.5) : UIColor.getThemeableColor(fromNormalColor: .white).withAlphaComponent(0.5)
        parentView.counterLabel.textColor = attachmentCell.photoImageView.image?.averageColor?.isLight ?? false ? .getThemeableColor(fromNormalColor: .white) : .getThemeableColor(fromNormalColor: .black)
    }
}

class AudioCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var audios = [AudioCellViewModel]()

    init() {
        let layout = UICollectionViewFlowLayout()
        super.init(frame: .zero, collectionViewLayout: layout)
        delegate = self
        dataSource = self
        
        backgroundColor = .getThemeableColor(fromNormalColor: .white)
        isScrollEnabled = false
    
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        
        isPagingEnabled = true
        
        register(UINib(nibName: "NewsFeedAudioCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "NewsFeedAudioCollectionViewCell")
    }
    
    func set(audios: [AudioCellViewModel]) {
        self.audios = audios
        contentOffset = CGPoint.zero
        reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return audios.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(withReuseIdentifier: "NewsFeedAudioCollectionViewCell", for: indexPath) as! NewsFeedAudioCollectionViewCell
        cell.audioTitleLabel.text = audios[indexPath.item].title
        cell.audioAuthorLabel.text = audios[indexPath.item].author
        cell.durationLabel.text = TimeInterval(audios[indexPath.item].duration).stringDuration
        
        cell.audioTitleLabel.sizeToFit()
        cell.audioAuthorLabel.sizeToFit()
        cell.durationLabel.sizeToFit()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .custom(collectionView.bounds.width, 58)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
