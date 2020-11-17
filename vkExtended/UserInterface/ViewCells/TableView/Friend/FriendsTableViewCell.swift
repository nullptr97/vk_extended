//
//  FriendsTableViewCell.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 26.10.2020.
//

import UIKit
import Material
import MaterialComponents

class FriendsTableViewCell: TableViewCell {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var friendNameLabel: UILabel!
    @IBOutlet weak var friendAdditionalLabel: UILabel!
    @IBOutlet weak var messageButton: UIButton!
    
    var firstAttributesName: [NSAttributedString.Key : Any] = [.font: GoogleSansFont.medium(with: 16), .foregroundColor: UIColor.adaptableBlack]
    var secondAttributesName: [NSAttributedString.Key : Any] = [.font: GoogleSansFont.bold(with: 16), .foregroundColor: UIColor.adaptableBlack]
    let attributesEtc: [NSAttributedString.Key : Any] = [.font: GoogleSansFont.regular(with: 14), .foregroundColor: UIColor.adaptableGrayVK]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .getThemeableColor(from: .white)
        contentView.backgroundColor = .getThemeableColor(from: .white)
        
        avatarImageView.setRounded()
        
        friendNameLabel.textColor = .getThemeableColor(from: .black)
        friendNameLabel.font = GoogleSansFont.medium(with: 16)
        
        friendAdditionalLabel.textColor = .systemBlue
        friendAdditionalLabel.font = GoogleSansFont.medium(with: 13)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setup(by viewModel: FriendCellViewModel) {
        messageButton.isHidden = viewModel.canWriteMessage == 0
        if let urlString = viewModel.photo100, let url = URL(string: urlString) {
            avatarImageView.kf.setImage(with: url)
        }
        friendNameLabel.attributedText = NSAttributedString(string: "\(viewModel.firstName!) ", attributes: firstAttributesName) + NSAttributedString(string: "\(viewModel.lastName!)", attributes: secondAttributesName)
        if viewModel.isOnline ?? false {
            if viewModel.isMobile ?? false {
                friendAdditionalLabel.text = "в сети с \(viewModel.onlinePlatform)"
            } else {
                friendAdditionalLabel.text = "в сети"
            }
        } else {
            friendAdditionalLabel.text = "не в сети"
        }
    }
}
