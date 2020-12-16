//
//  SuggestionCell.swift
//  VKExt
//
//  Created by programmist_NA on 15.07.2020.
//

import UIKit
import Material

protocol SuggestionCellDelegate: class {
    func likePost(for cell: SuggestionCell)
    func unlikePost(for cell: SuggestionCell)
}

final class SuggestionCell: Material.TableViewCell {
    static let reuseId = "SuggestionCell"
    weak var delegate: SuggestionCellDelegate?
    var isLiked: Bool = false

    fileprivate var card: PulseView = {
        let view = PulseView()
        view.backgroundColor = .adaptablePostColor
        return view
    }()
    
    /// Conent area.
    fileprivate var avatarButton = IconButton()
    fileprivate var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.setRounded()
        return imageView
    }()
    
    fileprivate var contentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    fileprivate var contentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = GoogleSansFont.medium(with: 14)
        label.textColor = .getThemeableColor(fromNormalColor: .black)
        label.backgroundColor = .adaptablePostColor
        return label
    }()
    
    /// Bottom Bar views.
    fileprivate var bottomBar = Bar(frame: CGRect(origin: .zero, size: CGSize(width: screenWidth, height: 28)))
    fileprivate var commentsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = GoogleSansFont.regular(with: 13)
        label.textColor = .getThemeableColor(fromNormalColor: .darkGray)
        label.backgroundColor = .adaptablePostColor
        return label
    }()
    fileprivate var likeButton = IconButton(image: UIImage(named: "like_outline_24")?.withRenderingMode(.alwaysTemplate).tint(with: .adaptableDarkGrayVK), tintColor: .adaptableDarkGrayVK)
    fileprivate var shareButton = IconButton(image: UIImage(named: "share_outline_24")?.withRenderingMode(.alwaysTemplate).tint(with: .adaptableDarkGrayVK), tintColor: .adaptableDarkGrayVK)
    
    /// Toolbar views.
    fileprivate var toolbar = Toolbar(frame: CGRect(origin: .zero, size: CGSize(width: screenWidth, height: 52)))
    fileprivate var moreButton = IconButton(image: Icon.cm.moreHorizontal, tintColor: .adaptableDarkGrayVK)
    
    override func prepareForReuse() {
        avatarImageView.image = nil
        contentImageView.image = nil
        contentLabel.text = nil
        commentsLabel.text = nil
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectionStyle = .none
        
        likeButton.addTarget(self, action: #selector(onLikePost), for: .touchUpInside)
        prepareToolbar()
        prepareBottomBar()
        preparePresenterCard()
    }
    
    func set(viewModel: FeedCellViewModel) {
        isLiked = viewModel.userLikes == 1
//        if viewModel.attachements.count > 0, let url = viewModel.attachments[0].photoUrlString {
//            contentImageView.kf.setImage(with: URL(string: url))
//        }
        toolbar.title = viewModel.name
        contentLabel.text = viewModel.text
        if viewModel.comments?.intValue ?? 0 > 0 {
            commentsLabel.text = "\(viewModel.comments ?? "") \(getStringByDeclension(number: viewModel.comments?.intValue ?? 0, arrayWords: Localization.commentsCount))"
        }
        avatarImageView.kf.setImage(with: URL(string: viewModel.iconUrlString))
    }
    
    @objc func onLikePost(_ sender: IconButton) {
        !isLiked ? delegate?.likePost(for: self) : delegate?.unlikePost(for: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension SuggestionCell {
    fileprivate func prepareToolbar() {
        avatarButton.addSubview(avatarImageView)
        avatarImageView.autoCenterInSuperview()
        avatarImageView.autoSetDimensions(to: CGSize(width: 32, height: 32))
        avatarImageView.drawBorder(16, width: 0, color: .clear, isOnlyTopCorners: false)

        toolbar.leftViews = [avatarButton]
        
        toolbar.titleLabel.textAlignment = .left
        toolbar.titleLabel.font = GoogleSansFont.medium(with: 16)
        toolbar.titleLabel.textColor = .getThemeableColor(fromNormalColor: .black)
        toolbar.backgroundColor = .getThemeableColor(fromNormalColor: .white)
    }
    
    fileprivate func prepareBottomBar() {
        bottomBar.leftViews = [likeButton, shareButton]
        bottomBar.rightViews = [moreButton]
        bottomBar.backgroundColor = .getThemeableColor(fromNormalColor: .white)
    }
    
    fileprivate func preparePresenterCard() {
        addSubview(card)
        card.addSubview(contentImageView)
        card.addSubview(toolbar)
        card.addSubview(contentLabel)
        card.addSubview(commentsLabel)
        card.addSubview(bottomBar)
        
        card.autoPinEdgesToSuperviewEdges(with: Constants.cardOffset)
        card.drawBorder(12, width: 0.5, color: .adaptablePostColor, isOnlyTopCorners: false)
        card.depthPreset = .depth1
        
        toolbar.autoPinEdge(.top, to: .top, of: card)
        toolbar.autoPinEdge(.trailing, to: .trailing, of: card)
        toolbar.autoPinEdge(.leading, to: .leading, of: card)
        
        toolbar.autoPinEdge(.bottom, to: .top, of: contentImageView)
        contentImageView.autoPinEdge(.trailing, to: .trailing, of: card)
        contentImageView.autoPinEdge(.leading, to: .leading, of: card)
        
        contentLabel.autoPinEdge(.top, to: .bottom, of: contentImageView, withOffset: 12)
        contentLabel.autoPinEdge(.trailing, to: .trailing, of: card, withOffset: -16)
        contentLabel.autoPinEdge(.leading, to: .leading, of: card, withOffset: 16)
        
        commentsLabel.autoPinEdge(.top, to: .bottom, of: contentLabel)
        commentsLabel.autoPinEdge(.trailing, to: .trailing, of: card, withOffset: -16)
        commentsLabel.autoPinEdge(.leading, to: .leading, of: card, withOffset: 16)
        
        bottomBar.autoPinEdge(.top, to: .bottom, of: commentsLabel)
        bottomBar.autoPinEdge(.trailing, to: .trailing, of: card)
        bottomBar.autoPinEdge(.leading, to: .leading, of: card)
        bottomBar.autoPinEdge(.bottom, to: .bottom, of: card)
    }
}
