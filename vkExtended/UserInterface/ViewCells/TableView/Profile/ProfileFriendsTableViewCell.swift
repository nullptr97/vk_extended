//
//  FriendsTableViewCell.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 28.10.2020.
//

import Foundation
import UIKit

class ProfileFriendsTableViewCell: UITableViewCell {
    var friendsCollectionView = FriendsCollectionView()
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
        typeLabel.attributedText = NSAttributedString(string: "Друзья   ", attributes: [.font: GoogleSansFont.semibold(with: 15), .foregroundColor: UIColor.getThemeableColor(fromNormalColor: .black)])
        
        contentView.addSubview(performButton)
        performButton.autoPinEdge(.top, to: .top, of: contentView, withOffset: 8)
        performButton.autoPinEdge(.trailing, to: .trailing, of: contentView, withOffset: -16)
        performButton.autoSetDimensions(to: .identity(22))
        
        performButton.setImage(UIImage(named: "chevron_down_24")?.withRenderingMode(.alwaysTemplate).tint(with: .adaptableDarkGrayVK), for: .normal)
        performButton.transform = CGAffineTransform(rotationAngle: .pi + (.pi / 2))
        
        contentView.addSubview(friendsCollectionView)
        friendsCollectionView.autoPinEdge(.top, to: .bottom, of: typeLabel, withOffset: 4)
        friendsCollectionView.autoPinEdge(.leading, to: .leading, of: contentView, withOffset: 16)
        friendsCollectionView.autoPinEdge(.trailing, to: .trailing, of: contentView, withOffset: -16)
        friendsCollectionView.autoPinEdge(.bottom, to: .bottom, of: contentView, withOffset: -2)
        friendsCollectionView.autoSetDimension(.height, toSize: 100)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCollection(friends: [FriendCellViewModel]) {
        friendsCollectionView.set(friends: friends)
        typeLabel.attributedText = NSAttributedString(string: "Друзья   ", attributes: [.font: GoogleSansFont.semibold(with: 15), .foregroundColor: UIColor.getThemeableColor(fromNormalColor: .black)]) + NSAttributedString(string: "\(friends.count)", attributes: [.font: GoogleSansFont.semibold(with: 12), .foregroundColor: UIColor.adaptableDarkGrayVK])
    }
}
