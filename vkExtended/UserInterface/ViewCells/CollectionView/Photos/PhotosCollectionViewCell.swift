//
//  PhotosCollectionViewCell.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 25.11.2020.
//

import UIKit
import IGListKit

class PhotosCollectionViewCell: UICollectionViewCell, ListBindable {
    var photosCollectionView = PhotosCollectionView()
    var typeLabel = UILabel()
    var performButton = UIButton()

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .getThemeableColor(fromNormalColor: .white)
        contentView.backgroundColor = .getThemeableColor(fromNormalColor: .white)
        
        contentView.addSubview(typeLabel)
        typeLabel.autoPinEdge(.top, to: .top, of: contentView, withOffset: 8)
        typeLabel.autoPinEdge(.leading, to: .leading, of: contentView, withOffset: 16)
        typeLabel.autoPinEdge(.trailing, to: .trailing, of: contentView, withOffset: -16)
        
        typeLabel.textColor = .getThemeableColor(fromNormalColor: .darkGray)
        typeLabel.font = GoogleSansFont.semibold(with: 15)
        typeLabel.attributedText = NSAttributedString(string: "Фотографии   ", attributes: [.font: GoogleSansFont.semibold(with: 15), .foregroundColor: UIColor.getThemeableColor(fromNormalColor: .black)])
        
        contentView.addSubview(performButton)
        performButton.autoPinEdge(.top, to: .top, of: contentView, withOffset: 8)
        performButton.autoPinEdge(.trailing, to: .trailing, of: contentView, withOffset: -16)
        performButton.autoSetDimensions(to: .identity(22))
        
        performButton.setImage(UIImage(named: "chevron_down_24")?.withRenderingMode(.alwaysTemplate).tint(with: .adaptableDarkGrayVK), for: .normal)
        performButton.transform = CGAffineTransform(rotationAngle: .pi + (.pi / 2))
        
        contentView.addSubview(photosCollectionView)
        photosCollectionView.autoPinEdge(.top, to: .bottom, of: typeLabel, withOffset: 4)
        photosCollectionView.autoPinEdge(.leading, to: .leading, of: contentView, withOffset: 16)
        photosCollectionView.autoPinEdge(.trailing, to: .trailing, of: contentView, withOffset: -16)
        photosCollectionView.autoPinEdge(.bottom, to: .bottom, of: contentView, withOffset: -8)
        photosCollectionView.autoSetDimension(.height, toSize: UIScreen.main.bounds.width / 4)
    }
    
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? ProfilePhotosViewModel else { return }
        photosCollectionView.set(photos: viewModel.cell)
        typeLabel.attributedText = NSAttributedString(string: "Фотографии   ", attributes: [.font: GoogleSansFont.semibold(with: 15), .foregroundColor: UIColor.getThemeableColor(fromNormalColor: .black)]) + NSAttributedString(string: "\(viewModel.count)", attributes: [.font: GoogleSansFont.semibold(with: 12), .foregroundColor: UIColor.getThemeableColor(fromNormalColor: .darkGray)])
        typeLabel.sizeToFit()
    }
}
