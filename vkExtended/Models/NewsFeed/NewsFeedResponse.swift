//
//  NewsFeedResponse.swift
//  VKExt
//
//  Created by programmist_NA on 11.07.2020.
//

import Foundation

struct FeedResponse: Decodable {
    var items: [FeedItem]
    var profiles: [Profile]
    var groups: [Group]
    var nextFrom: String?
}

struct FeedItem: Decodable {
    let type: String
    let sourceId: Int
    let postId: Int
    let text: String?
    let date: Double
    let comments: CountableCommentItem?
    let likes: CountableLikeItem?
    let reposts: CountableShareItem?
    let views: CountableViewItem?
    let attachments: [Attachment]?
    let copyHistory: [RepostItem]?
    let copyright: Copyright?
    let postSource: PostSource
}

struct PostSource: Decodable {
    let type: String
    let platform: String?
    let data: String?
}

struct Attachment: Decodable {
    let photo: Photo?
    let doc: Doc?
    let audioPlaylist: AudioPlaylist?
    let audio: Audio?
    let link: WallLink?
    let type: String?
}

// MARK: - Link
struct WallLink: Decodable {
    let title: String?
    let url: String?
    let caption: String?
    let photo: Photo?
}

struct Photo: Decodable {
    let sizes: [PhotoSize]
    
    var height: Int {
         return getPropperSize().height
    }
    
    var width: Int {
        return getPropperSize().width
    }
    
    var srcBIG: String {
         return getPropperSize().url
    }
    
    var srcMax: String {
         return getMaxSize().url
    }
    
    private func getPropperSize() -> PhotoSize {
        if let sizeX = sizes.first(where: { $0.type == "x" }) {
            return sizeX
        } else if let fallBackSize = sizes.last {
             return fallBackSize
        } else {
            return PhotoSize(type: "wrong image", url: "wrong image", width: 0, height: 0)
        }
    }
    
    private func getMaxSize() -> PhotoSize {
        if let sizeX = sizes.first(where: { $0.type == "w" }) {
            return sizeX
        } else if let fallBackSize = sizes.last {
             return fallBackSize
        } else {
            return PhotoSize(type: "wrong image", url: "wrong image", width: 0, height: 0)
        }
    }
}

struct PhotoSize: Decodable {
    let type: String
    let url: String
    let width: Int
    let height: Int
}

struct Doc: Decodable {
    let id, ownerId: Int
    let title: String
    let size: Int
    let ext: String
    let date, type: Int
    let url: String
    let preview: Preview?
    let accessKey: String
}

struct Preview: Decodable {
    let photo: PhotoDoc?
    let video: Video?
}

struct PhotoDoc: Decodable {
    let sizes: [PhotoDocSize]
    
    var height: Int {
         return getPropperSize().height
    }
    
    var width: Int {
        return getPropperSize().width
    }
    
    var srcBIG: String {
         return getPropperSize().src
    }
    
    var srcMax: String {
         return getMaxSize().src
    }
    
    private func getPropperSize() -> PhotoDocSize {
        if let sizeX = sizes.first(where: { $0.type == "x" }) {
            return sizeX
        } else if let fallBackSize = sizes.last {
             return fallBackSize
        } else {
            return PhotoDocSize(type: "wrong image", src: "wrong image", width: 0, height: 0)
        }
    }
    
    private func getMaxSize() -> PhotoDocSize {
        if let sizeX = sizes.first(where: { $0.type == "y" }) {
            return sizeX
        } else if let fallBackSize = sizes.last {
             return fallBackSize
        } else {
            return PhotoDocSize(type: "wrong image", src: "wrong image", width: 0, height: 0)
        }
    }
}

struct AudioPlaylist: Decodable {
    let id, ownerId, type: Int
    let title, audioPlaylistDescription: String
    let count, followers, plays, createTime: Int
    let updateTime: Int
    let isFollowing: Bool
    let audios: [Audio]
    let photo: PhotoAudio
    let accessKey, albumType: String
}

struct PhotoAudio: Decodable {
    let width, height: Int
    let photo34, photo68, photo135, photo270: String
    let photo300, photo600, photo1200: String
}

struct PhotoDocSize: Decodable {
    let type: String
    let src: String
    let width: Int
    let height: Int
}

struct Video: Decodable {
    let src: String
    let width, height: Int
    let type: String?
    let fileSize: Int?
}

struct CountableLikeItem: Decodable {
    let count: Int
    let userLikes: Int
    let canLike: Int
    let canPublish: Int
}

struct CountableCommentItem: Decodable {
    let count: Int
    let canPost: Int
}

struct CountableShareItem: Decodable {
    let count: Int
    let userReposted: Int
}

struct CountableViewItem: Decodable {
    let count: Int
}

enum RepresenatableType {
    case profile
    case group
}

protocol ProfileRepresenatable {
    var id: Int { get }
    var name: String { get }
    var photo: String { get }
    var verified: Int? { get }
    var pageType: RepresenatableType { get }
    var sex: Int? { get }
}

struct Profile: Decodable, ProfileRepresenatable {
    var verified: Int?
    
    let id: Int
    let firstName: String
    let lastName: String
    let photo100: String
    let sex: Int?
    
    var name: String { return firstName + " " + lastName }
    var photo: String { return photo100 }
    var pageType: RepresenatableType { return .profile }
}

struct Group: Decodable, ProfileRepresenatable {
    var verified: Int?
    
    let id: Int
    let name: String
    let photo100: String
    
    var photo: String { return photo100 }
    var pageType: RepresenatableType { return .group }
    var sex: Int? = 0
}


struct WallResponse: Decodable {
    var items: [WallItem]
    var profiles: [Profile]
    var groups: [Group]
    var count: Int
}

struct WallItem: Decodable {
    let postType: String
    let ownerId: Int
    let id: Int
    let text: String?
    let date: Double
    let comments: CountableCommentItem?
    let likes: CountableLikeItem?
    let reposts: CountableShareItem?
    let views: CountableViewItem?
    let attachments: [Attachment]?
    let copyHistory: [RepostItem]?
    let postSource: PostSource
}

struct RepostItem: Decodable {
    let postType: String
    let ownerId: Int
    let id: Int
    let text: String?
    let date: Double
    let attachments: [Attachment]?
    let postSource: PostSource
}

struct Copyright: Decodable {
    let id: Int?
    let link: String
    let type: String
    let name: String
}
