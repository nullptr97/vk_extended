//
//  NewsHeaderCollectionViewCell.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 21.11.2020.
//

import UIKit
import Material
import MaterialComponents
import IGListKit

class NewsHeaderCollectionViewCell: CollectionViewCell, ListBindable {
    
    @IBOutlet weak var avatarOwnerImageView: UIImageView!
    @IBOutlet weak var ownerNameLabel: UILabel!
    @IBOutlet weak var timePostLabel: UILabel!
    @IBOutlet weak var moreButton: MDCFlatButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .getThemeableColor(fromNormalColor: .white)
        contentView.backgroundColor = .getThemeableColor(fromNormalColor: .white)
        
        avatarOwnerImageView.setRounded()
        
        ownerNameLabel.textColor = .getThemeableColor(fromNormalColor: .black)
        ownerNameLabel.font = GoogleSansFont.medium(with: 16)
        
        timePostLabel.textColor = .getThemeableColor(fromNormalColor: .darkGray)
        timePostLabel.font = GoogleSansFont.regular(with: 13)
        
        moreButton.setBackgroundImage(UIImage(named: "more_horizontal_28")?.withRenderingMode(.alwaysTemplate).tint(with: .adaptableDarkGrayVK), for: .normal)
        moreButton.inkStyle = .unbounded
        moreButton.inkColor = UIColor.getAccentColor(fromType: .common).withAlphaComponent(0.2)
    }
    
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? NewsfeedHeaderViewModel else { return }
        avatarOwnerImageView.kf.setImage(with: URL(string: viewModel.iconUrlString))
        ownerNameLabel.text = viewModel.name
        timePostLabel.text = viewModel.date
        
        //ownerNameLabel.sizeToFit()
        timePostLabel.sizeToFit()
    }
}
