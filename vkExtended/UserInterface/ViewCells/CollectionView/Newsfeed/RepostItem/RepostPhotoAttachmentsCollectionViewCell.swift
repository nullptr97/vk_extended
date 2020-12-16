//
//  NewsfeedPhotoAttachmentsCollectionViewCell.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 22.11.2020.
//

import UIKit
import IGListKit

class RepostPhotoAttachmentsCollectionViewCell: UICollectionViewCell, ListBindable {
    
    var photoAttachmentsCollectionView = NewsAttachmentsCollectionView()
    let counterView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.getThemeableColor(from: .black).withAlphaComponent(0.7)
        view.clipsToBounds = true
        return view
    }()
    let counterLabel: UILabel = {
        let label = UILabel()
        label.textColor = .getThemeableColor(from: .white)
        label.font = GoogleSansFont.medium(with: 12)
        label.textAlignment = .center
        return label
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addSubview(photoAttachmentsCollectionView)
        photoAttachmentsCollectionView.autoPinEdgesToSuperviewEdges()
        
        addSubview(counterView)
        
        counterView.autoPinEdge(.trailing, to: .trailing, of: self, withOffset: -16)
        counterView.autoPinEdge(.top, to: .top, of: self, withOffset: 16)

        counterView.addSubview(counterLabel)

        counterLabel.autoPinEdgesToSuperviewEdges(with: .identity(6))
        
        counterView.drawBorder(13.25, width: 0.5, color: .clear, isOnlyTopCorners: false)
    }
    
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? NewsfeedPhotoAttachmentsViewModel else { return }
        photoAttachmentsCollectionView.set(photos: viewModel.photoAttachements)
    }
}
