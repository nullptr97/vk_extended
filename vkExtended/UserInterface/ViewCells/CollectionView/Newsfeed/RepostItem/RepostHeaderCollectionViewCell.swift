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

class RepostHeaderCollectionViewCell: CollectionViewCell, ListBindable {
    
    @IBOutlet weak var avatarOwnerImageView: UIImageView!
    @IBOutlet weak var ownerNameLabel: UILabel!
    @IBOutlet weak var timePostLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .getThemeableColor(fromNormalColor: .white)
        contentView.backgroundColor = .getThemeableColor(fromNormalColor: .white)
        
        avatarOwnerImageView.setRounded()
        
        ownerNameLabel.textColor = .getThemeableColor(fromNormalColor: .black)
        ownerNameLabel.font = GoogleSansFont.medium(with: 16)
        
        timePostLabel.textColor = .getThemeableColor(fromNormalColor: .darkGray)
        timePostLabel.font = GoogleSansFont.regular(with: 13)
    }
    
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? RepostHeaderViewModel else { return }
        avatarOwnerImageView.kf.setImage(with: URL(string: viewModel.iconUrlString))
        ownerNameLabel.attributedText = setLabelImage(image: "repost_12")! + NSAttributedString(string: " \(viewModel.name)", attributes: [.font: GoogleSansFont.medium(with: 16), .foregroundColor: UIColor.getThemeableColor(fromNormalColor: .black)])
        timePostLabel.text = viewModel.date
        
        ownerNameLabel.sizeToFit()
        timePostLabel.sizeToFit()
    }
}
