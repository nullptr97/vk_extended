//
//  ProfileMainInfoTableViewCell.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 26.10.2020.
//

import UIKit
import Kingfisher
import Material
import MaterialComponents

class ProfileMainInfoTableViewCell: UITableViewCell {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var etcInfoLabel: UILabel!
    @IBOutlet weak var userActionButton: MDCFlatButton!
    @IBOutlet weak var messageButton: MDCFlatButton!
    @IBOutlet weak var friendsCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var groupsCountLabel: UILabel!
    @IBOutlet weak var onlineImageView: UIImageView!
    @IBOutlet weak var freindsCountImageView: UIImageView!
    @IBOutlet weak var followersCountImageView: UIImageView!
    @IBOutlet weak var groupsCountImageView: UIImageView!
    
    private let attributesEtc: [NSAttributedString.Key : Any] = [.font: GoogleSansFont.regular(with: 14), .foregroundColor: UIColor.adaptableGrayVK]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .getThemeableColor(from: .white)
        contentView.backgroundColor = .getThemeableColor(from: .white)
        
        avatarImageView.drawBorder(48, width: 0.5, color: .adaptableDivider)
        
        nameLabel.textColor = .getThemeableColor(from: .black)
        etcInfoLabel.textColor = .adaptableDarkGrayVK
        friendsCountLabel.textColor = .adaptableDarkGrayVK
        followersCountLabel.textColor = .adaptableDarkGrayVK
        groupsCountLabel.textColor = .adaptableDarkGrayVK
        
        nameLabel.font = GoogleSansFont.bold(with: 20)
        etcInfoLabel.font = GoogleSansFont.regular(with: 16)
        friendsCountLabel.font = GoogleSansFont.semibold(with: 16)
        followersCountLabel.font = GoogleSansFont.semibold(with: 16)
        groupsCountLabel.font = GoogleSansFont.semibold(with: 16)
        
        freindsCountImageView.image = freindsCountImageView.image?.withRenderingMode(.alwaysTemplate).tint(with: .adaptableDarkGrayVK)
        followersCountImageView.image = followersCountImageView.image?.withRenderingMode(.alwaysTemplate).tint(with: .adaptableDarkGrayVK)
        groupsCountImageView.image = groupsCountImageView.image?.withRenderingMode(.alwaysTemplate).tint(with: .adaptableDarkGrayVK)
                
        userActionButton.setRounded()
        messageButton.setRounded()
        
        userActionButton.backgroundColor = .adaptablePostColor
        messageButton.backgroundColor = .adaptablePostColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setup(by viewModel: ProfileCellViewModel) {
        if let urlString = viewModel.photoMaxOrig, let url = URL(string: urlString) {
            KingfisherManager.shared.retrieveImage(with: url) { [weak self] (result) in
                guard let self = self else { return }
                switch result {
                case .success(let value):
                    self.avatarImageView.image = value.image
                    NotificationCenter.default.post(name: NSNotification.Name("loadProfileImage"), object: nil, userInfo: ["avatarAverageColor" : value.image.averageColor ?? .clear])
                case .failure(let error):
                    print(error.errorDescription ?? "Error load image")
                }
            }
        }
        
        nameLabel.text = "\(viewModel.firstName!) \(viewModel.lastName!)"
        etcInfoLabel.text = viewModel.status
        
        friendsCountLabel.text = "\(viewModel.friendsCount ?? 0)"
        followersCountLabel.text = "\(viewModel.followersCount ?? 0)"
        if viewModel.counters?.groups ?? 0 == 0 {
            groupsCountLabel.text = "\(viewModel.counters?.pages ?? 0)"
        } else {
            groupsCountLabel.text = "\(viewModel.counters?.groups ?? 0)"
        }
        
        setupButtons(hasCurrentUser: Constants.currentUserId == viewModel.id, canMessage: viewModel.type, friendAction: viewModel.friendActionType)
        
        if viewModel.isOnline ?? false {
            if viewModel.isMobile ?? false {
                onlineImageView.image = UIImage(named: "Online Mobile")
            } else {
                onlineImageView.image = UIImage(named: "Online")
            }
        } else {
            onlineImageView.image = nil
        }
    }
    
    func setupButtons(hasCurrentUser: Bool, canMessage: ProfileActionType, friendAction: FriendAction) {
        userActionButton.isHidden = hasCurrentUser
        messageButton.isHidden = hasCurrentUser || canMessage == .actionFriend

        userActionButton.setImage(UIImage(named: friendAction.setImage(from: friendAction))?.withRenderingMode(.alwaysTemplate).tint(with: .systemBlue)?.resize(toWidth: 24)?.resize(toHeight: 24), for: .normal)
    }
}
