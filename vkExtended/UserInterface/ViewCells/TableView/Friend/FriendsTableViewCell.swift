//
//  FriendsTableViewCell.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 26.10.2020.
//

import UIKit
import Material
import MaterialComponents
import Kingfisher

class FriendsTableViewCell: TableViewCell {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var friendNameLabel: UILabel!
    @IBOutlet weak var friendAdditionalLabel: UILabel!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var onlineImageView: UIImageView!
    @IBOutlet weak var stackHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var friendNameStackView: UIStackView!
    
    var firstAttributesName: [NSAttributedString.Key : Any] = [.font: GoogleSansFont.medium(with: 16), .foregroundColor: UIColor.adaptableBlack]
    var secondAttributesName: [NSAttributedString.Key : Any] = [.font: GoogleSansFont.bold(with: 16), .foregroundColor: UIColor.adaptableBlack]
    let attributesEtc: [NSAttributedString.Key : Any] = [.font: GoogleSansFont.regular(with: 14), .foregroundColor: UIColor.adaptableGrayVK]
    
    override func prepareForReuse() {
        super.prepareForReuse()
        friendNameLabel.text = nil
        friendNameLabel.attributedText = nil
        friendAdditionalLabel.text = nil
        friendAdditionalLabel.attributedText = nil
        avatarImageView.image = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .getThemeableColor(fromNormalColor: .white)
        contentView.backgroundColor = .getThemeableColor(fromNormalColor: .white)
        
        avatarImageView.setRounded()
        
        friendNameLabel.textColor = .getThemeableColor(fromNormalColor: .black)
        friendNameLabel.font = GoogleSansFont.medium(with: 16)
        
        friendAdditionalLabel.textColor = .getAccentColor(fromType: .common)
        friendAdditionalLabel.font = GoogleSansFont.medium(with: 13)
        
        messageButton.setImage(UIImage(named: "messages_outline_28 @ chats")?.withRenderingMode(.alwaysTemplate).tint(with: .getAccentColor(fromType: .common)), for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        messageButton.setImage(UIImage(named: "messages_outline_28 @ chats")?.withRenderingMode(.alwaysTemplate).tint(with: .getAccentColor(fromType: .common)), for: .normal)
    }
    
    func setup(by viewModel: FriendCellViewModel) {
        let statusImageView = UIImageView()
        statusImageView.autoSetDimensions(to: .identity(20))
        statusImageView.tag = 0x1999
        if friendNameStackView.arrangedSubviews.compactMap({ $0.viewWithTag(0x1999) }).isEmpty {
            friendNameStackView.addArrangedSubview(statusImageView)
        }
        
        messageButton.isHidden = viewModel.canWriteMessage == 0
        if let urlString = viewModel.photo100, let url = URL(string: urlString) {
            avatarImageView.kf.setImage(with: url)
        }
        friendNameLabel.attributedText = NSAttributedString(string: "\(viewModel.firstName!) ", attributes: firstAttributesName) + NSAttributedString(string: "\(viewModel.lastName!) ", attributes: secondAttributesName)
        friendNameLabel.sizeToFit()
        if let imgStatusUrl = URL(string: viewModel.imageStatusUrl) {
            statusImageView.kf.setImage(with: imgStatusUrl)
        } else {
            statusImageView.image = nil
        }
        onlineImageView.isHidden = !(viewModel.isOnline ?? false)
        onlineImageView.image = UIImage(named: viewModel.isMobile ?? false ? "Online Mobile" : "Online")
        
        var etcInfo: String = ""
        if let bdate = viewModel.bdate {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "ru_RU")
            dateFormatter.dateFormat = "dd.MM.YYYY"
            if let date = dateFormatter.date(from: bdate) {
                let calendar = Calendar.current
                if let year = calendar.dateComponents([.year], from: date).year, let currentYear = calendar.dateComponents([.year], from: Date()).year {
                    let age = "\(currentYear - year - 1) \(getStringByDeclension(number: currentYear - year - 1, arrayWords: Localization.ageCase))"
                    etcInfo.append(age)
                }
            }
        }
        if let city = viewModel.homeTown, !city.isEmpty {
            etcInfo.append(!etcInfo.isEmpty ? ", \(city)" : city)
        }
        if let school = viewModel.school, !school.isEmpty {
            etcInfo.append(!etcInfo.isEmpty ? ", \(school)" : school)
        }
        
        stackHeightConstraint.constant = etcInfo.isEmpty ? 22 : 38
        
        if !etcInfo.isEmpty {
            friendAdditionalLabel.text = etcInfo
            friendAdditionalLabel.sizeToFit()
        }
    }
}
