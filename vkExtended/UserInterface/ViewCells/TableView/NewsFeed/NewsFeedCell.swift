//
//  NewsFeedCell.swift
//  VKExt
//
//  Created by programmist_NA on 11.07.2020.
//

import Foundation
import UIKit
import Material
import IGListKit

protocol NewsFeedCellDelegate: class {
    func revealPost(for cell: UICollectionViewCell & ListBindable)
    func likePost(for cell: UICollectionViewCell & ListBindable)
    func unlikePost(for cell: UICollectionViewCell & ListBindable)
    func openPhoto(for cell: NewsFeedCell, with url: String?)
    func openComments(for cell: NewsFeedCell)
    func share(for cell: NewsFeedCell)
    func openLikesList(for cell: UICollectionViewCell & ListBindable)
}

final class NewsFeedCell: Material.TableViewCell {
    
    static let reuseId = "NewsFeedCell"
    
    weak var delegate: NewsFeedCellDelegate?
    
    var isLiked: Bool = false

    // Первый слой
    
    let cardView: UIView = {
       let view = UIView()
        view.backgroundColor = .getThemeableColor(fromNormalColor: .white)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Второй слой
    
    let topView: UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let topRepostView: UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let postlabel: UITextView = {
       let textView = UITextView()
        textView.backgroundColor = .clear
        textView.font = Constants.postLabelFont
        textView.isScrollEnabled = false
        textView.isSelectable = true
        textView.isUserInteractionEnabled = true
        textView.isEditable = false
        
        let padding = textView.textContainer.lineFragmentPadding
        textView.textContainerInset = UIEdgeInsets.init(top: 0, left: -padding, bottom: 0, right: -padding)
        
        textView.dataDetectorTypes = UIDataDetectorTypes.all
        return textView
    }()
    
    let moreTextButton: UIButton = {
       let button = UIButton()
        button.titleLabel?.font = GoogleSansFont.semibold(with: 14.5)
        button.setTitleColor(.getAccentColor(fromType: .common), for: .normal)
        button.contentHorizontalAlignment = .left
        button.contentVerticalAlignment = .center
        button.setTitle("Показать полностью...", for: .normal)
        return button
    }()
    
    let galleryCollectionView = GalleryCollectionView()
    
    let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .adaptableBackground
        imageView.isUserInteractionEnabled = true
        let tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onOpenPhoto))
        tapRecognizer.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(tapRecognizer)
        return imageView
    }()
    let gifImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .adaptableBackground
        imageView.isUserInteractionEnabled = true
        let tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onOpenPhoto))
        tapRecognizer.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(tapRecognizer)
        let textLabel = UILabel()
        textLabel.font = GoogleSansFont.medium(with: 12)
        textLabel.textColor = .getThemeableColor(fromNormalColor: .white)
        textLabel.backgroundColor = UIColor.adaptableTextPrimaryColor.withAlphaComponent(0.5)
        textLabel.text = "GIF"
        textLabel.drawBorder((textLabel.requiredHeight + 8) / 2, width: 0, color: .clear, isOnlyTopCorners: false)
        textLabel.padding = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        imageView.addSubview(textLabel)
        textLabel.autoPinEdge(.bottom, to: .bottom, of: imageView, withOffset: -8)
        textLabel.autoPinEdge(.trailing, to: .trailing, of: imageView, withOffset: -8)
        return imageView
    }()
    var postUrl: String? = ""
    
    let postButton: IconButton = {
        let imageView = IconButton()
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    let bottomView: UIView = {
       let view = UIView()
        return view
    }()
    
    // Третий слой на topView
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .adaptableBackground
        return imageView
    }()
    
    let nameLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = GoogleSansFont.medium(with: 16)
        label.numberOfLines = 0
        label.textColor = .adaptableTextPrimaryColor
        return label
    }()
    
    let dateLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .getThemeableColor(fromNormalColor: .darkGray)
        label.font = GoogleSansFont.regular(with: 13)
        return label
    }()
    
    // Четвертый слой на topView
    
    let iconRepostImageView: WebImageView = {
        let imageView = WebImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .adaptableBackground
        return imageView
    }()
    
    let nameRepostLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = GoogleSansFont.medium(with: 15)
        label.numberOfLines = 0
        label.textColor = .adaptableTextPrimaryColor
        return label
    }()
    
    let dateRepostLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .getThemeableColor(fromNormalColor: .darkGray)
        label.font = GoogleSansFont.regular(with: 12)
        return label
    }()
    
    // Третий слой на bottomView

    let likesView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let commentsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let sharesView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let viewsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Четвертый слой на bottomView
    
    let likesImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "like_outline_24")?.withRenderingMode(.alwaysTemplate).tint(with: .adaptableDarkGrayVK)
        return imageView
    }()
    
    let likesButton: IconButton = {
        let button = IconButton()
        button.autoSetDimensions(to: CGSize(width: 80, height: 44))
        return button
    }()
    
    let commentsImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "comment_outline_24")?.withRenderingMode(.alwaysTemplate).tint(with: .adaptableDarkGrayVK)
        return imageView
    }()
    
    let commentsButton: IconButton = {
        let button = IconButton()
        button.autoSetDimensions(to: CGSize(width: 80, height: 44))
        return button
    }()
    
    let sharesImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "share_outline_24")?.withRenderingMode(.alwaysTemplate).tint(with: .adaptableDarkGrayVK)
        return imageView
    }()
    
    let sharesButton: IconButton = {
        let button = IconButton()
        button.autoSetDimensions(to: CGSize(width: 80, height: 44))
        return button
    }()
    
    let viewsImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "view_outline_24")?.withRenderingMode(.alwaysTemplate).tint(with: .adaptableDarkGrayVK)
        return imageView
    }()
    
    let likesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = GoogleSansFont.medium(with: 14)
        label.textAlignment = .right
        label.lineBreakMode = .byClipping
        return label
    }()
    
    let commentsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .getThemeableColor(fromNormalColor: .darkGray)
        label.font = GoogleSansFont.medium(with: 14)
        label.textAlignment = .right
        label.lineBreakMode = .byClipping
        return label
    }()
    
    let sharesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .getThemeableColor(fromNormalColor: .darkGray)
        label.font = GoogleSansFont.medium(with: 14)
        label.lineBreakMode = .byClipping
        return label
    }()
    
    let viewsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .getThemeableColor(fromNormalColor: .darkGray)
        label.font = GoogleSansFont.medium(with: 14)
        label.textAlignment = .right
        label.lineBreakMode = .byClipping
        return label
    }()
    var findviewmodel: (NSAttributedString, [NSRange], [String])?
    var findrepost: (NSAttributedString, [NSRange], [String])?
    
    override func prepareForReuse() {
        iconImageView.image = nil
        iconRepostImageView.image = nil
        postImageView.image = nil
        gifImageView.image = nil
        likesLabel.text = nil
        commentsLabel.text = nil
        sharesLabel.text = nil
        viewsLabel.text = nil
        likesLabel.attributedText = nil
        commentsLabel.attributedText = nil
        sharesLabel.attributedText = nil
        viewsLabel.attributedText = nil
        nameLabel.text = nil
        nameLabel.attributedText = nil
        dateLabel.text = nil
        dateLabel.attributedText = nil
        postlabel.text = nil
        postlabel.attributedText = nil
        findviewmodel = nil
        findrepost = nil
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .getThemeableColor(fromNormalColor: .white)
//        dividerAlignment = .bottom
//        dividerColor = .getThemeableColor(fromNormalColor: .lightGray)
//        dividerThickness = 0.4
//        dividerContentEdgeInsets = .horizontal(16)
        
        iconImageView.layer.cornerRadius = Constants.topViewHeight / 2
        iconImageView.clipsToBounds = true
        
        iconRepostImageView.layer.cornerRadius = Constants.topRepostViewHeight / 2
        iconRepostImageView.clipsToBounds = true
        
        backgroundColor = .clear
        selectionStyle = .none
        
        cardView.layer.cornerRadius = 0
        cardView.clipsToBounds = true
        
        moreTextButton.addTarget(self, action: #selector(moreTextButtonTouch), for: .touchUpInside)
        postButton.addTarget(self, action: #selector(onOpenPhoto), for: .touchUpInside)
        
        overlayFirstLayer() // первый слой
        overlaySecondLayer() // второй слой
        overlaySecondRepostLayer()
        overlayLayerOnRepostView()
        overlayThirdLayerOnTopView() // третий слой на topView
        overlayThirdLayerOnBottomView() // третий слой на bottomView
        overlayFourthLayerOnBottomViewViews() // четвертый слой на bottomViewViews
    }
    
    @objc func onOpenPhoto() {
        delegate?.openPhoto(for: self, with: postUrl)
    }
    
    @objc func moreTextButtonTouch() {
    }
    
    @objc func onLikePost(_ sender: IconButton) {
//        !isLiked ? delegate?.likePost(for: self) : delegate?.unlikePost(for: self)
    }
    
    @objc func onUnLikePost(_ sender: IconButton) {
//        delegate?.unlikePost(for: self)
    }
    
    @objc func onOpenComments(_ sender: IconButton) {
        delegate?.openComments(for: self)
    }
    
    @objc func onShare(_ sender: IconButton) {
        delegate?.share(for: self)
    }
    
    func set(viewModel: FeedCellViewModel) {
        isLiked = viewModel.userLikes == 1
        iconRepostImageView.isHidden = viewModel.repost?.first == nil
        nameRepostLabel.isHidden = viewModel.repost?.first == nil
        dateRepostLabel.isHidden = viewModel.repost?.first == nil

        iconImageView.kf.setImage(with: URL(string: viewModel.iconUrlString))
        nameLabel.text = viewModel.name
        dateLabel.text = viewModel.date
        postlabel.attributedText = viewModel.text?.findNameFromBrackets.0
        findviewmodel = viewModel.text?.findNameFromBrackets

        likesLabel.text = viewModel.likes
        commentsLabel.text = viewModel.comments
        sharesLabel.text = viewModel.shares
        viewsLabel.text = viewModel.views
        
        postlabel.frame = viewModel.sizes.postLabelFrame
        
        bottomView.frame = viewModel.sizes.bottomViewFrame
        moreTextButton.frame = viewModel.sizes.moreTextButtonFrame
        
        likesLabel.textColor = viewModel.userLikes == 1 ? .extendedBackgroundRed : .adaptableDarkGrayVK
        likesImage.image = UIImage(named: viewModel.userLikes == 1 ? "like_24" : "like_outline_24")?.withRenderingMode(.alwaysTemplate).tint(with: viewModel.userLikes == 1 ? .extendedBackgroundRed : .adaptableDarkGrayVK)
        
        likesButton.addTarget(self, action: #selector(onLikePost), for: .touchUpInside)
        commentsButton.addTarget(self, action: #selector(onOpenComments), for: .touchUpInside)
        sharesButton.addTarget(self, action: #selector(onShare), for: .touchUpInside)

        if let repost = viewModel.repost?.first {
            iconRepostImageView.set(imageURL: repost.iconUrlString)
            nameRepostLabel.attributedText = setLabelImage(image: "repost_12")! + NSAttributedString(string: " \(repost.name)", attributes: [.font: GoogleSansFont.medium(with: 15), .foregroundColor: UIColor.adaptableTextPrimaryColor])
            dateRepostLabel.text = repost.date
            postlabel.attributedText = repost.text?.findNameFromBrackets.0
            findrepost = repost.text?.findNameFromBrackets
            
            if let gif = viewModel.photoAttachements.first?.gifUrl, let url = URL(string: gif) {
                postImageView.isHidden = true
                gifImageView.isHidden = false
                postButton.isHidden = false
                galleryCollectionView.isHidden = true
                gifImageView.setGifFromURL(url)
                postUrl = gif
                gifImageView.frame = viewModel.sizes.attachmentFrame
                postButton.frame = viewModel.sizes.attachmentFrame
            } else if let photoAttachment = repost.photoAttachements.first, repost.photoAttachements.count == 1, let urlString = photoAttachment.photoUrlString {
                postImageView.isHidden = false
                postButton.isHidden = false
                gifImageView.isHidden = true
                galleryCollectionView.isHidden = true
                postImageView.kf.setImage(with: URL(string: urlString))
                postUrl = photoAttachment.photoMaxUrl
                postImageView.frame = viewModel.sizes.attachmentFrame
                postButton.frame = viewModel.sizes.attachmentFrame
            } else if repost.photoAttachements.count > 1 {
                postImageView.isHidden = true
                postButton.isHidden = true
                gifImageView.isHidden = true
                galleryCollectionView.isHidden = false
                galleryCollectionView.frame = viewModel.sizes.attachmentFrame
                galleryCollectionView.set(photos: repost.photoAttachements)
            }
            else {
                postImageView.isHidden = true
                postButton.isHidden = true
                galleryCollectionView.isHidden = true
            }
        } else {
            if let gif = viewModel.photoAttachements.first?.gifUrl, let url = URL(string: gif) {
                postImageView.isHidden = true
                gifImageView.isHidden = false
                postButton.isHidden = false
                galleryCollectionView.isHidden = true
                gifImageView.setGifFromURL(url)
                postUrl = gif
                gifImageView.frame = viewModel.sizes.attachmentFrame
                postButton.frame = viewModel.sizes.attachmentFrame
            } else if let photoAttachment = viewModel.photoAttachements.first, viewModel.photoAttachements.count == 1, let urlString = photoAttachment.photoUrlString {
                postImageView.isHidden = false
                postButton.isHidden = false
                gifImageView.isHidden = true
                galleryCollectionView.isHidden = true
                postImageView.kf.setImage(with: URL(string: urlString))
                postUrl = photoAttachment.photoMaxUrl
                postImageView.frame = viewModel.sizes.attachmentFrame
                postButton.frame = viewModel.sizes.attachmentFrame
            } else if viewModel.photoAttachements.count > 1 {
                postImageView.isHidden = true
                postButton.isHidden = true
                gifImageView.isHidden = true
                galleryCollectionView.isHidden = false
                galleryCollectionView.frame = viewModel.sizes.attachmentFrame
                galleryCollectionView.set(photos: viewModel.photoAttachements)
            } else {
                postImageView.isHidden = true
                gifImageView.isHidden = true
                postButton.isHidden = true
                galleryCollectionView.isHidden = true
            }
        }
    }
    
    private func overlayFourthLayerOnBottomViewViews() {
        likesView.addSubviews([likesImage, likesLabel, likesButton])
        commentsView.addSubviews([commentsImage, commentsLabel, commentsButton])
        sharesView.addSubviews([sharesImage, sharesLabel, sharesButton])
        viewsView.addSubviews([viewsImage, viewsLabel])
        
        helpInFourthLayer(view: likesView, imageView: likesImage, label: likesLabel)
        helpInFourthLayer(view: commentsView, imageView: commentsImage, label: commentsLabel)
        helpInFourthLayer(view: sharesView, imageView: sharesImage, label: sharesLabel)
        helpInFourthLayer(view: viewsView, imageView: viewsImage, label: viewsLabel)
        
        likesButton.fillSuperview()
        commentsButton.fillSuperview()
        sharesButton.fillSuperview()
    }
    
    private func helpInFourthLayer(view: UIView, imageView: UIImageView, label: UILabel) {
        
        // label constraints
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4).isActive = true
        label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 4).isActive = true
        label.textAlignment = view == viewsView ? .left : .right
        
        // imageView constraints
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        if view == viewsView {
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4).isActive = true
        } else {
            imageView.trailingAnchor.constraint(equalTo: label.leadingAnchor, constant: -4).isActive = true
        }

        imageView.widthAnchor.constraint(equalToConstant: Constants.bottomViewViewsIconSize).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: Constants.bottomViewViewsIconSize).isActive = true
    }
    
    private func overlayThirdLayerOnBottomView() {
        bottomView.addSubview(likesView)
        bottomView.addSubview(commentsView)
        bottomView.addSubview(sharesView)
        bottomView.addSubview(viewsView)
        
        // likesView constraints
        viewsView.anchor(top: bottomView.topAnchor,
                         leading: bottomView.leadingAnchor,
                         bottom: nil,
                         trailing: nil,
                         padding: .custom(2, 0, 0, 0),
                         size: CGSize(width: Constants.bottomViewViewWidth, height: Constants.bottomViewViewHeight))
        
        // commentsView constraints
        sharesView.anchor(top: bottomView.topAnchor,
                            leading: nil,
                            bottom: nil,
                            trailing: commentsView.leadingAnchor,
                            padding: .custom(2, 0, 0, 0),
                            size: CGSize(width: Constants.bottomViewViewWidth, height: Constants.bottomViewViewHeight))
        
        // sharesView constraints
        commentsView.anchor(top: bottomView.topAnchor,
                          leading: nil,
                          bottom: nil,
                          trailing: likesView.leadingAnchor,
                          padding: .custom(2, 4, 0, 0),
                          size: CGSize(width: Constants.bottomViewViewWidth, height: Constants.bottomViewViewHeight))
        
        // viewsView constraints
        likesView.anchor(top: bottomView.topAnchor,
                         leading: nil,
                         bottom: nil,
                         trailing: bottomView.trailingAnchor,
                         padding: .custom(2, 4, 0, 0),
                         size: CGSize(width: Constants.bottomViewViewWidth, height: Constants.bottomViewViewHeight))
    }

    
    private func overlayThirdLayerOnTopView() {
        topView.addSubview(iconImageView)
        topView.addSubview(nameLabel)
        topView.addSubview(dateLabel)
        
        // iconImageView constraints
        iconImageView.leadingAnchor.constraint(equalTo: topView.leadingAnchor).isActive = true
        iconImageView.topAnchor.constraint(equalTo: topView.topAnchor).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: Constants.topViewHeight).isActive = true
        iconImageView.widthAnchor.constraint(equalToConstant: Constants.topViewHeight).isActive = true
        
        // nameLabel constraints
        nameLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -8).isActive = true
        nameLabel.topAnchor.constraint(equalTo: topView.topAnchor, constant: 4).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: Constants.topViewHeight / 2 - 2).isActive = true
        
        // dateLabel constraints
        dateLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8).isActive = true
        dateLabel.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -8).isActive = true
        dateLabel.bottomAnchor.constraint(equalTo: topView.bottomAnchor, constant: -6).isActive = true
        dateLabel.heightAnchor.constraint(equalToConstant: 14).isActive = true
    }

    private func overlaySecondLayer() {
        cardView.addSubview(topView)
        cardView.addSubview(postlabel)
        cardView.addSubview(moreTextButton)
        cardView.addSubview(postImageView)
        cardView.addSubview(gifImageView)
        cardView.addSubview(galleryCollectionView)
        cardView.addSubview(bottomView)
        cardView.addSubview(postButton)
        
        // topView constraints
        topView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12).isActive = true
        topView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12).isActive = true
        topView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 10).isActive = true
        topView.heightAnchor.constraint(equalToConstant: Constants.topViewHeight).isActive = true
    }
    
    private func overlaySecondRepostLayer() {
        cardView.addSubview(topRepostView)
        topRepostView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12).isActive = true
        topRepostView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12).isActive = true
        topRepostView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 8).isActive = true
        topRepostView.heightAnchor.constraint(equalToConstant: Constants.topRepostViewHeight).isActive = true
        
        overlayLayerOnRepostView()
    }
    
    private func overlayLayerOnRepostView() {
        topRepostView.addSubview(iconRepostImageView)
        topRepostView.addSubview(nameRepostLabel)
        topRepostView.addSubview(dateRepostLabel)
        
        // iconImageView constraints
        iconRepostImageView.leadingAnchor.constraint(equalTo: topRepostView.leadingAnchor).isActive = true
        iconRepostImageView.topAnchor.constraint(equalTo: topRepostView.topAnchor).isActive = true
        iconRepostImageView.heightAnchor.constraint(equalToConstant: Constants.topRepostViewHeight).isActive = true
        iconRepostImageView.widthAnchor.constraint(equalToConstant: Constants.topRepostViewHeight).isActive = true
        
        // nameLabel constraints
        nameRepostLabel.leadingAnchor.constraint(equalTo: iconRepostImageView.trailingAnchor, constant: 8).isActive = true
        nameRepostLabel.trailingAnchor.constraint(equalTo: topRepostView.trailingAnchor, constant: -8).isActive = true
        nameRepostLabel.topAnchor.constraint(equalTo: topRepostView.topAnchor, constant: 3).isActive = true
        nameRepostLabel.heightAnchor.constraint(equalToConstant: Constants.topRepostViewHeight / 2 - 2).isActive = true
        
        // dateLabel constraints
        dateRepostLabel.leadingAnchor.constraint(equalTo: iconRepostImageView.trailingAnchor, constant: 8).isActive = true
        dateRepostLabel.trailingAnchor.constraint(equalTo: topRepostView.trailingAnchor, constant: -8).isActive = true
        dateRepostLabel.bottomAnchor.constraint(equalTo: topRepostView.bottomAnchor, constant: -5).isActive = true
        dateRepostLabel.heightAnchor.constraint(equalToConstant: 14).isActive = true
    }
    
    private func overlayFirstLayer() {
        addSubview(cardView)
        
        // cardView constraints
        cardView.fillSuperview(padding: Constants.cardInsets)
        cardView.drawBorder(0, width: 0.5, color: .adaptableWhite)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        cardView.drawBorder(0, width: 0.5, color: .adaptableWhite)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

