//
//  NewsFooterCollectionViewCell.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 21.11.2020.
//

import UIKit
import Material
import IGListKit
import AudioToolbox

class NewsFooterCollectionViewCell: UICollectionViewCell, ListBindable {
    @IBOutlet weak var likesView: View!
    @IBOutlet weak var commentsView: View!
    @IBOutlet weak var repostsView: View!
    @IBOutlet weak var viewsView: View!
    
    @IBOutlet weak var likesImageView: UIImageView!
    @IBOutlet weak var commentsImageView: UIImageView!
    @IBOutlet weak var repostsImageView: UIImageView!
    @IBOutlet weak var viewsImageView: UIImageView!
    
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var repostsLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentsButton: UIButton!
    @IBOutlet weak var repostButton: UIButton!
    
    weak var delegate: NewsFeedCellDelegate?
    
    var viewModel: NewsfeedFooterViewModel?
    var isLikedPost: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .getThemeableColor(fromNormalColor: .white)
        
        likesView.backgroundColor = .getThemeableColor(fromNormalColor: .white)
        commentsView.backgroundColor = .getThemeableColor(fromNormalColor: .white)
        repostsView.backgroundColor = .getThemeableColor(fromNormalColor: .white)
        viewsView.backgroundColor = .getThemeableColor(fromNormalColor: .white)

        commentsImageView.image = UIImage(named: "comment_outline_24")?.withRenderingMode(.alwaysTemplate).tint(with: .adaptableDarkGrayVK)
        repostsImageView.image = UIImage(named: "share_outline_24")?.withRenderingMode(.alwaysTemplate).tint(with: .adaptableDarkGrayVK)
        viewsImageView.image = UIImage(named: "view_outline_24")?.withRenderingMode(.alwaysTemplate).tint(with: .adaptableDarkGrayVK)
        
        commentsLabel.textColor = .getThemeableColor(fromNormalColor: .darkGray)
        repostsLabel.textColor = .getThemeableColor(fromNormalColor: .darkGray)
        viewsLabel.textColor = .getThemeableColor(fromNormalColor: .darkGray)

        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(onGetLikesList(gestureRecognizer:)))
        likeButton.addGestureRecognizer(longPressGestureRecognizer)
    }

    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? NewsfeedFooterViewModel else { return }
        self.viewModel = viewModel
        
        isLikedPost = viewModel.userLikes == 1
        
        viewsView.isHidden = viewModel.views == ""
        likesImageView.image = UIImage(named: viewModel.userLikes == 0 ? "like_outline_24" : "like_24")?.withRenderingMode(.alwaysTemplate).tint(with: viewModel.userLikes == 0 ? .adaptableDarkGrayVK : .extendedBackgroundRed)
        likesLabel.textColor = viewModel.userLikes == 0 ? .adaptableDarkGrayVK : .extendedBackgroundRed
        
        likesLabel.text = viewModel.likes
        commentsLabel.text = viewModel.comments
        repostsLabel.text = viewModel.shares
        viewsLabel.text = viewModel.views
        
        likesLabel.sizeToFit()
        commentsLabel.sizeToFit()
        repostsLabel.sizeToFit()
        viewsLabel.sizeToFit()
        
        likesLabel.sizeToFit()
        commentsLabel.sizeToFit()
        repostsLabel.sizeToFit()
        viewsLabel.sizeToFit()
    }
    
    
    @IBAction func onLikePost(_ sender: Any) {
        VibrationFeedback.selection.generateFeedback()
        if !isLikedPost {
            delegate?.likePost(for: self)
            
            likesImageView.image = UIImage(named: "like_24")?.withRenderingMode(.alwaysTemplate).tint(with: .extendedBackgroundRed)
            likesLabel.textColor = .extendedBackgroundRed
            
            var likesCount = viewModel?.likes?.int ?? 0
            likesCount += 1

            likesLabel.text = "\(likesCount)"
        } else {
            delegate?.unlikePost(for: self)
            
            likesImageView.image = UIImage(named: "like_outline_24")?.withRenderingMode(.alwaysTemplate).tint(with: .adaptableDarkGrayVK)
            likesLabel.textColor = .adaptableDarkGrayVK
            
            var likesCount = viewModel?.likes?.int ?? 0
            likesCount -= 1

            likesLabel.text = likesCount <= 0 ? "" : "\(likesCount)"
        }
    }
    
    @objc func onGetLikesList(gestureRecognizer: UILongPressGestureRecognizer) {
        guard gestureRecognizer.state == .began else { return }
        delegate?.openLikesList(for: self)
    }
}
