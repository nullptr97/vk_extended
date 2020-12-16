//
//  ProfileCommonInfoCollectionViewCell.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 25.11.2020.
//

import UIKit
import Material
import IGListKit
import Kingfisher

protocol FriendActionDelegate: class {
    func action(for cell: UICollectionViewCell & ListBindable, with action: FriendAction)
    func openImagePopup(for cell: UICollectionViewCell & ListBindable, with userId: Int)
}

class ProfileCommonInfoCollectionViewCell: UICollectionViewCell, ListBindable {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UITextView!
    @IBOutlet weak var etcInfoLabel: UILabel!
    @IBOutlet weak var userActionButton: FlatButton!
    @IBOutlet weak var messageButton: FlatButton!
    @IBOutlet weak var editProfileButton: FlatButton!
    @IBOutlet weak var onlineImageView: UIImageView!
    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var editButtonStackView: UIStackView!
    @IBOutlet weak var fullInfoButton: FlatButton!
    
    @IBOutlet weak var counters: UIStackView!

    @IBOutlet weak var buttonsConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var statusLabelHeightConstraint: NSLayoutConstraint!
    
    weak var delegate: FriendActionDelegate?

    var friendAction: FriendAction?
    var userId: Int?

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .getThemeableColor(fromNormalColor: .white)
        contentView.backgroundColor = .getThemeableColor(fromNormalColor: .white)
        
        avatarImageView.drawBorder(48, width: 0.5, color: .getThemeableColor(fromNormalColor: .lightGray))
        
        nameLabel.textColor = .getThemeableColor(fromNormalColor: .black)
        etcInfoLabel.textColor = .getThemeableColor(fromNormalColor: .darkGray)
        
        nameLabel.font = GoogleSansFont.bold(with: 20)
        etcInfoLabel.font = GoogleSansFont.regular(with: 16)
                
        userActionButton.setCorners(radius: 10)
        messageButton.setCorners(radius: 10)
        editProfileButton.setCorners(radius: 10)
        fullInfoButton.setCorners(radius: 10)

        userActionButton.backgroundColor = .getAccentColor(fromType: .button)
        messageButton.backgroundColor = .getAccentColor(fromType: .button)
        editProfileButton.backgroundColor = .getAccentColor(fromType: .secondaryButton)
        fullInfoButton.backgroundColor = .getAccentColor(fromType: .secondaryButton)
        
        userActionButton.setTitleColor(.getThemeableColor(fromNormalColor: .white), for: .normal)
        messageButton.setTitleColor(.getThemeableColor(fromNormalColor: .white), for: .normal)
        editProfileButton.setTitleColor(.getAccentColor(fromType: .button), for: .normal)
        fullInfoButton.setImage(UIImage(named: "info_circle_outline_28")?.withRenderingMode(.alwaysTemplate).tint(with: .getAccentColor(fromType: .button)), for: .normal)
        fullInfoButton.imageEdgeInsets = .identity(8)
        
        userActionButton.titleLabel?.font = GoogleSansFont.medium(with: 15)
        messageButton.titleLabel?.font = GoogleSansFont.medium(with: 15)
        editProfileButton.titleLabel?.font = GoogleSansFont.medium(with: 15)
        
        userActionButton.titleLabel?.adjustsFontSizeToFitWidth = true
        messageButton.titleLabel?.adjustsFontSizeToFitWidth = true
        editProfileButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        userActionButton.titleLabel?.allowsDefaultTighteningForTruncation = true
        messageButton.titleLabel?.allowsDefaultTighteningForTruncation = true
        editProfileButton.titleLabel?.allowsDefaultTighteningForTruncation = true
        
        nameLabel.isUserInteractionEnabled = true
        nameLabel.textContainerInset = .zero
        nameLabel.textContainer.lineFragmentPadding = 0
        nameLabel.add(AttachmentTapGestureRecognizer(target: self, action: #selector(onTapImageStatus(sender:))))
    }

    func setupButtons(hasDeactivated: Bool, hasCurrentUser: Bool, canMessage: ProfileActionType, friendAction: FriendAction) {
        buttonsConstraint.isActive = !hasDeactivated
        avatarViewConstraint.isActive = hasDeactivated
        
        editButtonStackView.isHidden = !hasCurrentUser
        buttonsStackView.isHidden = hasCurrentUser || hasDeactivated
        
        guard !hasCurrentUser else { return }
        
        messageButton.isEnabled = canMessage == .actionFriendWithMessage
        messageButton.alpha = canMessage == .actionFriendWithMessage ? 1 : 0.5

        userActionButton.setTitle(friendAction.setTitle(from: friendAction), for: .normal)
        userActionButton.backgroundColor = friendAction.setColors(from: friendAction).0
        userActionButton.setTitleColor(friendAction.setColors(from: friendAction).1, for: .normal)
    }
    
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? ProfileCommonInfoViewModel else { return }
        userId = viewModel.id
        friendAction = viewModel.friendActionType
        
        if let url = URL(string: viewModel.photoMax) {
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

        if let imgStatusUrl = URL(string: viewModel.imageStatusUrl) {
            KingfisherManager.shared.retrieveImage(with: imgStatusUrl) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let value):
                    self.nameLabel.attributedText = NSAttributedString(string: viewModel.name, attributes: [.font: GoogleSansFont.bold(with: 20), .foregroundColor: UIColor.getThemeableColor(fromNormalColor: .black)]) + attributedSpace + setLabelImage(image: value.image)!
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        } else {
            nameLabel.text = viewModel.name
        }
        
        if let status = viewModel.status, !status.isEmpty {
            etcInfoLabel.text = viewModel.status
        } else {
            etcInfoLabel.text = nil
        }
        
        nameLabel.sizeToFit()
        etcInfoLabel.sizeToFit()
        
        _ = counters.subviews.map { $0.removeFromSuperview() }
        
        if viewModel.counters?.friends ?? 0 > 0 {
            let button = FlatButton()
            button.title = " \(viewModel.counters?.friends ?? 0)"
            button.image = UIImage(named: "users_outline_28")?.withRenderingMode(.alwaysTemplate).crop(toWidth: 18, toHeight: 18)?.tint(with: .getThemeableColor(fromNormalColor: .darkGray))
            button.titleColor = .getThemeableColor(fromNormalColor: .darkGray)
            button.titleLabel?.font = GoogleSansFont.medium(with: 15)
            counters.addArrangedSubview(button)
        }
        
        if viewModel.counters?.followers ?? 0 > 0 {
            let button = FlatButton()
            button.title = " \(viewModel.counters?.followers ?? 0)"
            button.image = UIImage(named: "followers_outline_20")?.withRenderingMode(.alwaysTemplate).crop(toWidth: 18, toHeight: 18)?.tint(with: .getThemeableColor(fromNormalColor: .darkGray))
            button.titleColor = .getThemeableColor(fromNormalColor: .darkGray)
            button.titleLabel?.font = GoogleSansFont.medium(with: 15)
            counters.addArrangedSubview(button)
        }
        
        if viewModel.counters?.groups ?? 0 > 0 || viewModel.counters?.pages ?? 0 > 0 {
            let button = FlatButton()
            if viewModel.counters?.groups ?? 0 == 0 {
                button.title = " \(viewModel.counters?.pages ?? 0)"
            } else {
                button.title = " \(viewModel.counters?.groups ?? 0)"
            }
            button.image = UIImage(named: "users_3_outline_28")?.withRenderingMode(.alwaysTemplate).crop(toWidth: 18, toHeight: 18)?.tint(with: .getThemeableColor(fromNormalColor: .darkGray))
            button.titleColor = .getThemeableColor(fromNormalColor: .darkGray)
            button.titleLabel?.font = GoogleSansFont.medium(with: 15)
            counters.addArrangedSubview(button)
        }
        
        setupButtons(hasDeactivated: viewModel.deactivated, hasCurrentUser: currentUserId == viewModel.id, canMessage: viewModel.type, friendAction: viewModel.friendActionType)
        
        if viewModel.isOnline {
            if viewModel.isMobile {
                onlineImageView.image = UIImage(named: "Online Mobile")
            } else {
                onlineImageView.image = UIImage(named: "Online")
            }
        } else {
            onlineImageView.image = nil
        }
    }

    @IBAction func onAction(_ sender: FlatButton) {
        guard let friendAction = friendAction else { return }
        delegate?.action(for: self, with: friendAction)
    }
    
    @objc func onTapImageStatus(sender: UITapGestureRecognizer) {
        guard let userId = userId else { return }
        delegate?.openImagePopup(for: self, with: userId)
    }
}
