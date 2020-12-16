//
//  NewsfeedCellLayoutCalculator.swift
//  VKExt
//
//  Created by programmist_NA on 11.07.2020.
//

import Foundation
import UIKit

struct CellSizes: FeedCellSizes {
    var postLabelFrame: CGRect
    var repostLabelFrame: CGRect
    var moreTextButtonFrame: CGRect
    var attachmentFrame: CGRect
    var bottomViewFrame: CGRect
    var totalHeight: CGFloat
}

protocol FeedCellLayoutCalculatorProtocol {
    func sizes(postText: String?, repostText: String?, photoAttachments: [AttachmentCellViewModel], isFullSizedPost: Bool) -> FeedCellSizes
    func suggestionSizes(postText: String?, repostText: String?, photoAttachment: [AttachmentCellViewModel]) -> FeedCellSizes
}

final class FeedCellLayoutCalculator: FeedCellLayoutCalculatorProtocol {
    private let screenWidth: CGFloat
    
    init(screenWidth: CGFloat = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)) {
        self.screenWidth = screenWidth
    }

    func sizes(postText: String?, repostText: String?, photoAttachments: [AttachmentCellViewModel], isFullSizedPost: Bool) -> FeedCellSizes {
        var showMoreTextButton = false
        let cardViewWidth = screenWidth - 16 - 16
        
        // MARK: Работа с postLabelFrame
        var postLabelFrame = CGRect(origin: CGPoint(x: Constants.postLabelInsets.left, y: Constants.postLabelInsets.top), size: CGSize.zero)
        
        if let text = postText, !text.isEmpty {
            let width = cardViewWidth - Constants.postLabelInsets.left - Constants.postLabelInsets.right
            var height: CGFloat
            let postLabelFont = GoogleSansFont.regular(with: 15)
            height = text.height(with: width, font: postLabelFont)
            
            let limitHeight = postLabelFont.lineHeight * Constants.minifiedPostLimitLines
            
            if !isFullSizedPost && height > limitHeight {
                height = postLabelFont.lineHeight * Constants.minifiedPostLines
                showMoreTextButton = true
            }
            
            postLabelFrame.size = CGSize(width: width, height: height)
        }
        
        var repostLabelFrame = CGRect(origin: CGPoint(x: Constants.postLabelInsets.left, y: Constants.postLabelRepostInsets.top ), size: CGSize.zero)
        
        if let text = repostText, !text.isEmpty {
            let width = cardViewWidth - Constants.postLabelRepostInsets.left - Constants.postLabelRepostInsets.right
            var height: CGFloat
            let postLabelFont = GoogleSansFont.regular(with: 15)
            height = text.height(with: width, font: postLabelFont)
            
            let limitHeight = postLabelFont.lineHeight * Constants.minifiedPostLimitLines
            
            if !isFullSizedPost && height > limitHeight {
                height = postLabelFont.lineHeight * Constants.minifiedPostLines
                showMoreTextButton = true
            }
            
            repostLabelFrame.size = CGSize(width: width, height: height)
        }
        
        // MARK: Работа с moreTextButtonFrame
        
        var moreTextButtonSize = CGSize.zero
        
        if showMoreTextButton {
            moreTextButtonSize = Constants.moreTextButtonSize
        }
        
        let moreTextButtonOrigin = CGPoint(x: Constants.moreTextButtonInsets.left, y: postLabelFrame.maxY)
        
        let moreTextButtonFrame = CGRect(origin: moreTextButtonOrigin, size: moreTextButtonSize)
        
        // MARK: Работа с attachmentFrame
        
        let attachmentTop: CGFloat
        if postLabelFrame.size == CGSize.zero {
            attachmentTop = Constants.postLabelInsets.top
        } else {
            attachmentTop = moreTextButtonFrame.maxY + Constants.postLabelInsets.bottom
        }
        
        var attachmentFrame = CGRect(origin: CGPoint(x: photoAttachments.count > 0 ? 8 : 0, y: attachmentTop),
                                     size: CGSize.zero)
        
        if let attachment = photoAttachments.first {
            let photoHeight: Float = attachment.height.float
            let photoWidth: Float = attachment.width.float
            let ratio = CGFloat(photoHeight / photoWidth)
            if photoAttachments.count == 1 {
                attachmentFrame.size = CGSize(width: cardViewWidth, height: cardViewWidth * ratio)
            } else if photoAttachments.count > 1 {
                var photos = [CGSize]()
                for photo in photoAttachments {
                    let photoSize = CGSize(width: CGFloat(photo.width), height: CGFloat(photo.height))
                    photos.append(photoSize)
                }
                let rowHeight = screenWidth
                attachmentFrame.size = CGSize(width: cardViewWidth, height: rowHeight)
            }
        }
        
        // MARK: Работа с bottomViewFrame
        
        let bottomViewTop = max(postLabelFrame.maxY, attachmentFrame.maxY)
        
        let bottomViewFrame = CGRect(origin: CGPoint(x: 8, y: bottomViewTop),
                                     size: CGSize(width: cardViewWidth, height: Constants.bottomViewHeight))
        
        // MARK: Работа с totalHeight
        
        let totalHeight = bottomViewFrame.maxY + Constants.cardInsets.bottom
        
        return CellSizes(postLabelFrame: postLabelFrame,
                         repostLabelFrame: repostLabelFrame,
                         moreTextButtonFrame: moreTextButtonFrame,
                         attachmentFrame: attachmentFrame,
                         bottomViewFrame: bottomViewFrame,
                         totalHeight: totalHeight)
    }
    
    func suggestionSizes(postText: String?, repostText: String?, photoAttachment: [AttachmentCellViewModel]) -> FeedCellSizes {
        var showMoreTextButton = false
        let cardViewWidth = screenWidth - Constants.cardInsets.left - Constants.cardInsets.right
        
        // MARK: Работа с postLabelFrame
        var postLabelFrame = CGRect(origin: CGPoint(x: Constants.postLabelInsets.left, y: Constants.postLabelInsets.top),
                                    size: CGSize.zero)
        
        if let text = postText, !text.isEmpty {
            let width = cardViewWidth - Constants.postLabelInsets.left - Constants.postLabelInsets.right
            var height = text.height(with: width, font: Constants.postLabelFont)
            
            let limitHeight = Constants.postLabelFont.lineHeight * Constants.minifiedPostLimitLines
            
            if height > limitHeight {
                height = Constants.postLabelFont.lineHeight * Constants.minifiedPostLines
                showMoreTextButton = true
            }
            
            postLabelFrame.size = CGSize(width: width, height: height)
        }
        // MARK: Работа с moreTextButtonFrame
        
        var moreTextButtonSize = CGSize.zero
        
        if showMoreTextButton {
            moreTextButtonSize = Constants.moreTextButtonSize
        }
        
        let moreTextButtonOrigin = CGPoint(x: Constants.moreTextButtonInsets.left, y: postLabelFrame.maxY)
        
        let moreTextButtonFrame = CGRect(origin: moreTextButtonOrigin, size: moreTextButtonSize)
        
        // MARK: Работа с attachmentFrame
        
        let attachmentTop = postLabelFrame.size == CGSize.zero ? Constants.postLabelInsets.top : moreTextButtonFrame.maxY + Constants.postLabelInsets.bottom
        
        var attachmentFrame = CGRect(origin: CGPoint(x: 0, y: attachmentTop),
                                     size: CGSize.zero)
        
        if let attachment = photoAttachment.first {
            let photoHeight: Float = Float(156)
            let photoWidth: Float = Float(attachment.width)
            let ratio = CGFloat(photoHeight / photoWidth)
            attachmentFrame.size = CGSize(width: cardViewWidth, height: cardViewWidth * ratio)
        }
        
        // MARK: Работа с bottomViewFrame
        
        let bottomViewTop = max(postLabelFrame.maxY, attachmentFrame.maxY)
        
        let bottomViewFrame = CGRect(origin: CGPoint(x: 0, y: bottomViewTop),
                                     size: CGSize(width: cardViewWidth, height: Constants.bottomViewHeight))
        
        // MARK: Работа с totalHeight
        
        let totalHeight = bottomViewFrame.maxY + Constants.cardInsets.bottom
        
        return CellSizes(postLabelFrame: postLabelFrame,
                         repostLabelFrame: .zero,
                         moreTextButtonFrame: moreTextButtonFrame,
                         attachmentFrame: attachmentFrame,
                         bottomViewFrame: bottomViewFrame,
                         totalHeight: totalHeight)
    }
}
