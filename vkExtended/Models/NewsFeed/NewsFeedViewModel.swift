//
//  NewsFeedViewModel.swift
//  VKExt
//
//  Created by programmist_NA on 11.07.2020.
//

import Foundation
import UIKit

enum AttachmentType: String {
    case sticker
    case audio
    case photo
    case video
    case doc
    case link
    case market
    case marketAlbum = "market_album"
    case wall
    case wallReply = "wall_reply"
    case gift
}

enum Newsfeed {
    enum Model {
        struct Request {
            enum RequestType {
                case getNewsfeed
                case getStories
                case getSuggestions
                case revealPostIds(postId: Int)
                case getNextBatch
                case like(postId: Int, sourceId: Int, type: String)
                case unlike(postId: Int, sourceId: Int, type: String)
            }
        }
        struct Response {
            enum ResponseType {
                case presentNewsfeed(feed: FeedResponse, revealdedPostIds: [Int])
                case presentSuggestions(feed: FeedResponse, revealdedPostIds: [Int])
                case presentFooterLoader
                case presentFooterError(message: String)
            }
        }
        struct ViewModel {
            enum ViewModelData {
                case displayNewsfeed(feedViewModel: FeedViewModel)
                case displayFooterLoader
                case displayFooterError(message: String)
            }
        }
    }
}

struct FeedViewModel {
    struct Cell: FeedCellViewModel {
        var postId: Int
        var sourceId: Int
        var type: String
        
        var iconUrlString: String
        var name: String
        var date: String
        var text: String?
        var likes: String?
        var userLikes: Int?
        var comments: String?
        var shares: String?
        var views: String?
        var photoAttachements: [AttachmentCellViewModel]
        var repost: [FeedRepostCellViewModel]?
        var sizes: FeedCellSizes
    }
    
    struct FeedCellPhotoAttachment: AttachmentCellViewModel {
        var gifUrl: String?
        var photoUrlString: String?
        var photoMaxUrl: String?
        var width: Int
        var height: Int
    }
    
    struct FeedRepost: FeedRepostCellViewModel {
        var id: Int
        var ownerId: Int
        var type: String
        
        var iconUrlString: String
        var name: String
        var date: String
        var text: String?
        var photoAttachements: [AttachmentCellViewModel]
    }
    
    var cells: [Cell]
    let footerTitle: String?
}

protocol FeedCellViewModel {
    var iconUrlString: String { get }
    var name: String { get }
    var date: String { get }
    var text: String? { get }
    var likes: String? { get }
    var userLikes: Int? { get }
    var comments: String? { get }
    var shares: String? { get }
    var views: String? { get }
    var photoAttachements: [AttachmentCellViewModel] { get }
    var repost: [FeedRepostCellViewModel]? { get }
    var sizes: FeedCellSizes { get }
}

protocol FeedRepostCellViewModel {
    var id: Int { get }
    var ownerId: Int { get }
    var type: String { get }
    
    var iconUrlString: String { get }
    var name: String { get }
    var date: String { get }
    var text: String? { get }
    var photoAttachements: [AttachmentCellViewModel] { get }
}

protocol FeedCellSizes {
    var postLabelFrame: CGRect { get }
    var attachmentFrame: CGRect { get }
    var bottomViewFrame: CGRect { get }
    var totalHeight: CGFloat { get }
    var moreTextButtonFrame: CGRect { get }
}

protocol AttachmentCellViewModel {
    var photoUrlString: String? { get }
    var photoMaxUrl: String? { get }
    var gifUrl: String? { get }
    var width: Int { get }
    var height: Int { get }
}
