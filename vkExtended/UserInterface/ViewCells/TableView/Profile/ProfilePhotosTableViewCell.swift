//
//  ProfilePhotosTableViewCell.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 28.10.2020.
//

import UIKit
import MaterialComponents

class ProfilePhotosTableViewCell: UITableViewCell {
    var photosCollectionView = PhotosCollectionView()
    var typeLabel = UILabel()
    var performButton = UIButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
        photosCollectionView.autoPinEdge(.bottom, to: .bottom, of: contentView, withOffset: -2)
        photosCollectionView.autoSetDimension(.height, toSize: UIScreen.main.bounds.width / 4)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCollection(photos: [PhotoCellViewModel]) {
        photosCollectionView.set(photos: photos)
        typeLabel.attributedText = NSAttributedString(string: "Фотографии   ", attributes: [.font: GoogleSansFont.semibold(with: 15), .foregroundColor: UIColor.getThemeableColor(fromNormalColor: .black)]) + NSAttributedString(string: "\(photos.count)", attributes: [.font: GoogleSansFont.semibold(with: 12), .foregroundColor: UIColor.adaptableDarkGrayVK])
    }
}
