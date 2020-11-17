//
//  FriendCollectionViewCell.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 28.10.2020.
//

import UIKit

protocol FriendFrofileDelegate: class {
    func onTapFriend(from cell: FriendCollectionViewCell, with userId: Int)
}

class FriendCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var friendImageView: UIImageView!
    @IBOutlet weak var friendNameLabel: UILabel!
    
    var userId: Int = 0
    weak var delegate: FriendFrofileDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapFriend)))
        
        friendImageView.drawBorder(28, width: 0.5, color: .adaptableDivider)
    }
    
    @objc func onTapFriend() {
        delegate?.onTapFriend(from: self, with: userId)
    }
}
