//
//  FriendsCollectionView.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 28.10.2020.
//

import Foundation
import UIKit
import ViewAnimator

class FriendsCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var friends = [FriendCellViewModel]()
    var isAnimated: Bool = false

    init() {
        let layout = UICollectionViewFlowLayout()
        super.init(frame: .zero, collectionViewLayout: layout)
        delegate = self
        dataSource = self
        
        backgroundColor = .getThemeableColor(fromNormalColor: .white)
        
        layout.scrollDirection = .horizontal
        
        isScrollEnabled = true
        alwaysBounceVertical = false
        
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        
        register(UINib(nibName: "FriendCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FriendCollectionViewCell")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(friends: [FriendCellViewModel]) {
        self.friends = friends
        reloadData()
        guard !isAnimated else { return }
        performBatchUpdates({
            UIView.animate(views: orderedVisibleCells, animations: [AnimationType.vector((CGVector(dx: 45, dy: 0)))]) { [weak self] in
                guard let self = self else { return }
                self.isAnimated = true
            }
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return friends.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(withReuseIdentifier: "FriendCollectionViewCell", for: indexPath) as! FriendCollectionViewCell
        cell.userId = friends[indexPath.item].id ?? currentUserId
        cell.delegate = self
        if friends.count > 0, let url = URL(string: friends[indexPath.item].photo100 ?? "") {
            cell.friendImageView.kf.setImage(with: url)
        }
        cell.friendNameLabel.attributedText = NSAttributedString(string: friends[indexPath.item].firstName! + "\n", attributes: [.foregroundColor: UIColor.getThemeableColor(fromNormalColor: .black), .font: GoogleSansFont.medium(with: 11)]) + NSAttributedString(string: friends[indexPath.item].lastName!, attributes: [.foregroundColor: UIColor.getThemeableColor(fromNormalColor: .black), .font: GoogleSansFont.semibold(with: 11)])
        cell.setupOnline(isOnline: friends[indexPath.item].isOnline ?? false, isMobile: friends[indexPath.item].isMobile ?? false)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .custom((collectionView.bounds.width / 6), 110)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard indexPath.item == friends.count - 5, let profileViewController = parentViewController as? ProfileViewController else { return }
        profileViewController.presenter?.start(request: .getFriends(userId: profileViewController.userId))
    }
}
extension FriendsCollectionView: FriendFrofileDelegate {
    func onTapFriend(from cell: FriendCollectionViewCell, with userId: Int) {
        parentViewController?.navigationController?.pushViewController(ProfileViewController(userId: userId))
    }
}
