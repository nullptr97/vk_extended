//
//  FriendsCollectionViewCell.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 09.12.2020.
//

import Foundation
import IGListKit

class FriendsCollectionViewCell: UICollectionViewCell, ListBindable {
    var friendsCollectionView = FriendsCollectionView()
    var typeLabel = UILabel()
    var performButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
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
        friendsCollectionView.backgroundColor = .clear
        friendsCollectionView.autoPinEdge(.top, to: UIDevice.type.rawValue <= 6 ? .top : .bottom, of: UIDevice.type.rawValue <= 6 ? contentView : typeLabel, withOffset: UIDevice.type.rawValue >= 6 ? 4 : 22)
        friendsCollectionView.autoPinEdge(.bottom, to: .bottom, of: contentView, withOffset: UIDevice.type.rawValue >= 6 ? -8 : 0)
        friendsCollectionView.autoPinEdge(.leading, to: .leading, of: contentView, withOffset: 0)
        friendsCollectionView.autoPinEdge(.trailing, to: .trailing, of: contentView, withOffset: 0)
        friendsCollectionView.autoSetDimension(.height, toSize: UIScreen.main.bounds.width / 4)
        friendsCollectionView.contentInset.left = 12
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? ProfileFriendsViewModel else { return }
        friendsCollectionView.set(friends: viewModel.cell)
        typeLabel.attributedText = NSAttributedString(string: "Друзья   ", attributes: [.font: GoogleSansFont.semibold(with: 15), .foregroundColor: UIColor.getThemeableColor(fromNormalColor: .black)]) + NSAttributedString(string: "\(viewModel.count)", attributes: [.font: GoogleSansFont.semibold(with: 12), .foregroundColor: UIColor.getThemeableColor(fromNormalColor: .darkGray)])
        typeLabel.sizeToFit()
    }
}
