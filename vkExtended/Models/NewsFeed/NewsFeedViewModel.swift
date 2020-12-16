//
//  NewsFeedViewModel.swift
//  VKExt
//
//  Created by programmist_NA on 11.07.2020.
//

import Foundation
import UIKit
import IGListKit

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
                case getNewsfeed(sourceIds: String = "")
                case getSuggestions
                case getTopics
                case revealPostIds(postId: Int)
                case getNextBatch
                case like(postId: Int, sourceId: Int, type: String)
                case unlike(postId: Int, sourceId: Int, type: String)
            }
        }
        struct Response {
            enum ResponseType {
                case presentNewsfeed(feed: FeedResponse, revealdedPostIds: [Int])
                case presentTopics(topics: [(Int, String)])
                case presentSuggestions(feed: FeedResponse, revealdedPostIds: [Int])
                case presentFooterLoader
                case presentFooterError(message: String)
            }
        }
        struct ViewModel {
            enum ViewModelData {
                case displayNewsfeed(feedViewModel: FeedViewModel)
                case displayTopics(topics: [Topic])
                case displayFooterLoader
                case displayFooterError(message: String)
            }
        }
    }
}

struct FeedViewModel {
    class Cell: FeedCellViewModel, ListDiffable {
        private var identifier: String = UUID().uuidString

        var postId: Int
        var sourceId: Int
        var type: String
        
        var iconUrlString: String
        var id: Int
        var name: String
        var date: String
        var text: String?
        var likes: String?
        var userLikes: Int?
        var comments: String?
        var shares: String?
        var views: String?
        var photoAttachements: [AttachmentCellViewModel]
        var audioAttachments: [AudioCellViewModel]
        var eventAttachments: [EventCellViewModel]
        var repost: [FeedRepostCellViewModel]?
        var sizes: FeedCellSizes
        
        init(postId: Int, sourceId: Int, type: String, iconUrlString: String, id: Int, name: String, date: String, text: String?, likes: String?, userLikes: Int?, comments: String?, shares: String?, views: String?, photoAttachements: [AttachmentCellViewModel], audioAttachments: [AudioCellViewModel], eventAttachments: [EventCellViewModel], repost: [FeedRepostCellViewModel]?, sizes: FeedCellSizes) {
            self.postId = postId
            self.sourceId = sourceId
            self.type = type
            self.iconUrlString = iconUrlString
            self.id = id
            self.name = name
            self.date = date
            self.text = text
            self.likes = likes
            self.userLikes = userLikes
            self.comments = comments
            self.shares = shares
            self.views = views
            self.photoAttachements = photoAttachements
            self.audioAttachments = audioAttachments
            self.eventAttachments = eventAttachments
            self.repost = repost
            self.sizes = sizes
        }
        
        func diffIdentifier() -> NSObjectProtocol {
            return identifier as NSString
        }
        
        func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
            guard let object = object as? Cell else {
                return false
            }
            
            return self.identifier == object.identifier
        }
    }
    
    struct FeedCellPhotoAttachment: AttachmentCellViewModel {
        var gifUrl: String?
        var photoUrlString: String?
        var photoMaxUrl: String?
        var width: Int
        var height: Int
    }
    
    struct FeedCellAudioAttachment: AudioCellViewModel {
        var title: String?
        var author: String?
        var url: String?
        var duration: Int
    }
    
    struct FeedCellEventAttachment: EventCellViewModel {
        var eventImageUrl: String
        var eventName: String
        var buttonText: String
        var id: Int
        var isFavorite: Bool
        var text: String
        var memberStatus: Int
        var time: Int
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
        var audioAttachments: [AudioCellViewModel]
        var eventAttachments: [EventCellViewModel]
    }
    
    var cells: [Cell]
    let footerTitle: String?
}

protocol FeedCellViewModel {
    var iconUrlString: String { get }
    var id: Int { get }
    var name: String { get }
    var date: String { get }
    var text: String? { get }
    var likes: String? { get }
    var userLikes: Int? { get }
    var comments: String? { get }
    var shares: String? { get }
    var views: String? { get }
    var photoAttachements: [AttachmentCellViewModel] { get }
    var audioAttachments: [AudioCellViewModel] { get }
    var eventAttachments: [EventCellViewModel] { get }
    var repost: [FeedRepostCellViewModel]? { get }
    var sizes: FeedCellSizes { get }
}

//class NewsfeedAttachmentsViewModel: ListDiffable {
//    var photoAttachements: [AttachmentCellViewModel] { get }
//}
//
//class NewsfeedFooterViewModel {
//    var likes: String? { get }
//    var userLikes: Int? { get }
//    var comments: String? { get }
//    var shares: String? { get }
//    var views: String? { get }
//}

protocol FeedRepostCellViewModel {
    var id: Int { get }
    var ownerId: Int { get }
    var type: String { get }
    
    var iconUrlString: String { get }
    var name: String { get }
    var date: String { get }
    var text: String? { get }
    var photoAttachements: [AttachmentCellViewModel] { get }
    var audioAttachments: [AudioCellViewModel] { get }
    var eventAttachments: [EventCellViewModel] { get }
}

protocol FeedCellSizes {
    var postLabelFrame: CGRect { get }
    var repostLabelFrame: CGRect { get }
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

protocol AudioCellViewModel {
    var title: String? { get }
    var author: String? { get }
    var url: String? { get }
    var duration: Int { get }
}

protocol EventCellViewModel {
    var eventImageUrl: String { get }
    var eventName: String { get }
    var buttonText: String { get }
    var id: Int { get }
    var isFavorite: Bool { get }
    var text: String { get }
    var memberStatus: Int { get }
    var time: Int { get }
}
