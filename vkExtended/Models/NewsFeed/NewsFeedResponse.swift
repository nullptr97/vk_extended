//
//  NewsFeedResponse.swift
//  VKExt
//
//  Created by programmist_NA on 11.07.2020.
//

import Foundation
import SwiftyJSON
import IGListKit

class FeedResponse: ListDiffable {
    private var identifier: String = UUID().uuidString

    var items: [FeedItem]
    var profiles: [Profile]
    var groups: [Group]
    var nextFrom: String?
    
    init(from news: JSON) {
        self.items = news["items"].arrayValue.compactMap { FeedItem(from: $0) }
        self.profiles = news["profiles"].arrayValue.compactMap { Profile(from: $0) }
        self.groups = news["groups"].arrayValue.compactMap { Group(from: $0) }
        self.nextFrom = news["next_from"].string
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? FeedResponse else {
            return false
        }
        
        return self.identifier == object.identifier
    }
}

class FeedItem: ListDiffable {
    private var identifier: String = UUID().uuidString

    var type: String
    var sourceId: Int
    var postId: Int
    var text: String?
    var date: Double
    var markedAsAds: Bool
    var comments: CountableCommentItem?
    var likes: CountableLikeItem?
    var reposts: CountableShareItem?
    var views: CountableViewItem?
    var attachments: [Attachment]?
    var copyHistory: [RepostItem]?
    var copyright: Copyright?
    var postSource: PostSource
    
    init(from feedItem: JSON) {
        self.type = feedItem["type"].stringValue
        self.sourceId = feedItem["source_id"].intValue
        self.postId = feedItem["post_id"].intValue
        self.text = feedItem["text"].string
        self.date = feedItem["date"].doubleValue
        self.markedAsAds = feedItem["marked_as_ads"].intValue.boolValue
        self.comments = CountableCommentItem(from: feedItem["comments"])
        self.likes = CountableLikeItem(from: feedItem["likes"])
        self.reposts = CountableShareItem(from: feedItem["reposts"])
        self.views = CountableViewItem(from: feedItem["views"])
        self.attachments = feedItem["attachments"].array?.compactMap { Attachment(from: $0) }
        self.copyHistory = feedItem["copy_history"].array?.compactMap { RepostItem(from: $0) }
        if feedItem["copyright"] != JSON.null {
            self.copyright = Copyright(from: feedItem["copyright"])
        } else {
            self.copyright = nil
        }
        self.postSource = PostSource(from: feedItem["post_source"])
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? FeedItem else {
            return false
        }
        
        return self.identifier == object.identifier
    }
}

struct PostSource {
    var type: String
    var platform: String?
    var data: String?
    
    init(from postSource: JSON) {
        self.type = postSource["type"].stringValue
        self.platform = postSource["platform"].stringValue
        self.data = postSource["data"].stringValue
    }
}

struct Attachment {
    var photo: Photo?
    var doc: Doc?
    var audioPlaylist: AudioPlaylist?
    var link: WallLink?
    var audio: Audio?
    var event: EventAttachment?
    var type: String?
    
    init(from attachment: JSON) {
        self.photo = Photo(from: attachment["photo"])
        self.doc = Doc(from: attachment["doc"])
        self.audio = Audio(audio: attachment["audio"])
        self.event = EventAttachment(event: attachment["event"])
        self.type = attachment["type"].string
    }
}

// MARK: - Audio
struct Audio {
    let artist: String
    let id, ownerId: Int
    let title: String
    let duration: Int
    let isExplicit, isFocusTrack: Bool
    let trackCode: String
    let url: String
    let date, albumId: Int
    let mainArtists: [MainArtist]
    let shortVideosAllowed, storiesAllowed, storiesCoverAllowed: Bool
    
    init(audio: JSON) {
        self.artist = audio["artist"].stringValue
        self.id = audio["id"].intValue
        self.ownerId = audio["owner_id"].intValue
        self.title = audio["title"].stringValue
        self.duration = audio["duration"].intValue
        self.isExplicit = audio["is_explicit"].boolValue
        self.isFocusTrack = audio["is_focus_track"].boolValue
        self.date = audio["date"].intValue
        self.trackCode = audio["track_code"].stringValue
        self.url = audio["url"].stringValue
        self.albumId = audio["album_id"].intValue
        self.mainArtists = audio["main_artist"].arrayValue.compactMap { MainArtist(artist: $0) }
        self.shortVideosAllowed = audio["short_videos_allowed"].boolValue
        self.storiesAllowed = audio["stories_allowed"].boolValue
        self.storiesCoverAllowed = audio["stories_cover_cllowed"].boolValue
    }
}

// MARK: - MainArtist
struct MainArtist: Codable {
    let name, domain, id: String
    
    init(artist: JSON) {
        self.name = artist["name"].stringValue
        self.domain = artist["domain"].stringValue
        self.id = artist["id"].stringValue
    }
}

// MARK: - Link
struct WallLink {
    var title: String?
    var url: String?
    var caption: String?
    var photo: Photo?
    
    init(from link: JSON) {
        
    }
}

struct EventAttachment {
    var buttonText: String
    let id: Int
    var isFavorite: Bool
    let text: String
    let memberStatus, time: Int

    init(event: JSON) {
        self.buttonText = event["button_text"].stringValue
        self.id = event["id"].intValue
        self.isFavorite = event["is_favorite"].boolValue
        self.text = event["text"].stringValue
        self.memberStatus = event["member_status"].intValue
        self.time = event["time"].intValue
    }
}

struct Photo {
    var sizes: [PhotoSize]
    
    var height: Int {
        return mediuimSize?.height ?? 0
    }
    
    var width: Int {
        return mediuimSize?.width ?? 0
    }
    
    var srcBIG: String {
        return mediuimSize?.url ?? ""
    }
    
    var srcMax: String {
        return maximumSize?.url ?? ""
    }
    
    private var mediuimSize: PhotoSize? {
        if let sizeTypeX = sizes.first(where: { $0.type == "x" }) {
            return sizeTypeX
        } else if let failSize = sizes.last {
            return failSize
        } else {
            return nil
        }
    }
    
    private var maximumSize: PhotoSize? {
        if let sizeTypeX = sizes.first(where: { $0.type == "w" }) {
            return sizeTypeX
        } else if let failSize = sizes.last {
            return failSize
        } else {
            return nil
        }
    }
    
    init(from photo: JSON) {
        self.sizes = photo["sizes"].arrayValue.compactMap { PhotoSize(from: $0) }
    }
}

struct PhotoSize {
    var type: String
    var url: String
    var width: Int
    var height: Int
    
    init(from size: JSON) {
        self.type = size["type"].stringValue
        self.url = size["url"].stringValue
        self.width = size["width"].intValue
        self.height = size["height"].intValue
    }
}

struct Doc: Decodable {
    var id, ownerId: Int
    var title: String
    var size: Int
    var ext: String
    var date, type: Int
    var url: String
    var preview: Preview?
    var accessKey: String
    
    init(from doc: JSON) {
        self.id = doc["id"].intValue
        self.ownerId = doc["owner_id"].intValue
        self.title = doc["title"].stringValue
        self.size = doc["size"].intValue
        self.ext = doc["ext"].stringValue
        self.date = doc["date"].intValue
        self.type = doc["type"].intValue
        self.url = doc["url"].stringValue
        self.preview = Preview(from: doc["preview"])
        self.accessKey = doc["access_key"].stringValue
    }
}

struct Preview: Decodable {
    var photo: PhotoDoc?
    var video: Video?
    
    init(from preview: JSON) {
        self.photo = PhotoDoc(from: preview["photo"])
        self.video = Video(from: preview["video"])
    }
}

struct PhotoDoc: Decodable {
    var sizes: [PhotoDocSize]
    
    var height: Int {
        return mediuimSize?.height ?? 0
    }
    
    var width: Int {
        return mediuimSize?.width ?? 0
    }
    
    var srcBIG: String {
        return mediuimSize?.src ?? ""
    }
    
    var srcMax: String {
        return maximumSize?.src ?? ""
    }
    
    private var mediuimSize: PhotoDocSize? {
        if let sizeTypeX = sizes.first(where: { $0.type == "x" }) {
            return sizeTypeX
        } else if let failSize = sizes.last {
            return failSize
        } else {
            return nil
        }
    }
    
    private var maximumSize: PhotoDocSize? {
        if let sizeTypeX = sizes.first(where: { $0.type == "w" }) {
            return sizeTypeX
        } else if let failSize = sizes.last {
            return failSize
        } else {
            return nil
        }
    }
    
    init(from photo: JSON) {
        self.sizes = photo["sizes"].arrayValue.compactMap { PhotoDocSize(from: $0) }
    }
}

struct AudioPlaylist: Decodable {
    var id, ownerId, type: Int
    var title, audioPlaylistDescription: String
    var count, followers, plays, createTime: Int
    var updateTime: Int
    var isFollowing: Bool
    var photo: PhotoAudio
    var accessKey, albumType: String
}

struct PhotoAudio: Decodable {
    var width, height: Int
    var photo34, photo68, photo135, photo270: String
    var photo300, photo600, photo1200: String
}

struct PhotoDocSize: Decodable {
    var type: String
    var src: String
    var width: Int
    var height: Int
    
    init(from size: JSON) {
        self.type = size["type"].stringValue
        self.src = size["src"].stringValue
        self.width = size["width"].intValue
        self.height = size["height"].intValue
    }
}

struct Video: Decodable {
    var src: String
    var width, height: Int
    var type: String?
    var fileSize: Int?
    
    init(from video: JSON) {
        self.src = video["src"].stringValue
        self.width = video["width"].intValue
        self.height = video["height"].intValue
        self.fileSize = video["file_size"].int
    }
}

struct CountableLikeItem: Decodable {
    var count: Int
    var userLikes: Int
    var canLike: Int
    var canPublish: Int
    
    init(from likes: JSON) {
        self.count = likes["count"].intValue
        self.userLikes = likes["user_likes"].intValue
        self.canLike = likes["can_like"].intValue
        self.canPublish = likes["can_publish"].intValue
    }
}

struct CountableCommentItem: Decodable {
    var count: Int
    var canPost: Int
    
    init(from comment: JSON) {
        self.count = comment["count"].intValue
        self.canPost = comment["can_post"].intValue
    }
}

struct CountableShareItem: Decodable {
    var count: Int
    var userReposted: Int
    
    init(from shares: JSON) {
        self.count = shares["count"].intValue
        self.userReposted = shares["user_reposted"].intValue
    }
}

struct CountableViewItem: Decodable {
    var count: Int
    
    init(from views: JSON) {
        self.count = views["count"].intValue
    }
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

class Profile: Decodable, ProfileRepresenatable, ListDiffable {
    private var identifier: String = UUID().uuidString
    
    var verified: Int?
    
    var id: Int
    var firstName: String
    var lastName: String
    var photo100: String
    var sex: Int?
    
    var name: String { return firstName + " " + lastName }
    var photo: String { return photo100 }
    var pageType: RepresenatableType { return .profile }
    
    init(from profile: JSON) {
        self.verified = profile["verified"].int
        self.id = profile["id"].intValue
        self.firstName = profile["first_name"].stringValue
        self.lastName = profile["last_name"].stringValue
        self.photo100 = profile["photo_100"].stringValue
        self.sex = profile["sex"].int
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? Profile else {
            return false
        }
        
        return self.identifier == object.identifier
    }
}

struct Group: Decodable, ProfileRepresenatable {
    var verified: Int?
    
    var id: Int
    var name: String
    var photo100: String
    
    var photo: String { return photo100 }
    var pageType: RepresenatableType { return .group }
    var sex: Int? = 0
    
    init(from group: JSON) {
        self.verified = group["verified"].int
        self.id = group["id"].intValue
        self.name = group["name"].stringValue
        self.photo100 = group["photo_100"].stringValue
    }
}


class WallResponse: ListDiffable {
    private var identifier: String = UUID().uuidString

    var items: [WallItem]
    var profiles: [Profile]
    var groups: [Group]
    var count: Int
    
    init(from wall: JSON) {
        self.items = wall["items"].arrayValue.compactMap { WallItem(from: $0) }
        self.profiles = wall["profiles"].arrayValue.compactMap { Profile(from: $0) }
        self.groups = wall["groups"].arrayValue.compactMap { Group(from: $0) }
        self.count = wall["count"].intValue
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? WallResponse else {
            return false
        }
        
        return self.identifier == object.identifier
    }
}

class WallItem: ListDiffable {
    private var identifier: String = UUID().uuidString

    var postType: String
    var ownerId: Int
    var id: Int
    var text: String?
    var date: Double
    var comments: CountableCommentItem?
    var likes: CountableLikeItem?
    var reposts: CountableShareItem?
    var views: CountableViewItem?
    var attachments: [Attachment]?
    var copyHistory: [RepostItem]?
    var postSource: PostSource
    
    init(from wallItem: JSON) {
        self.postType = wallItem["post_type"].stringValue
        self.ownerId = wallItem["owner_id"].intValue
        self.id = wallItem["id"].intValue
        self.text = wallItem["text"].string
        self.date = wallItem["date"].doubleValue
        self.comments = CountableCommentItem(from: wallItem["comments"])
        self.likes = CountableLikeItem(from: wallItem["likes"])
        self.reposts = CountableShareItem(from: wallItem["reposts"])
        self.views = CountableViewItem(from: wallItem["views"])
        self.attachments = wallItem["attachments"].array?.compactMap { Attachment(from: $0) }
        self.copyHistory = wallItem["copy_history"].array?.compactMap { RepostItem(from: $0) }
        self.postSource = PostSource(from: wallItem["post_source"])
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? WallItem else {
            return false
        }
        
        return self.identifier == object.identifier
    }
}

struct RepostItem {
    var postType: String
    var ownerId: Int
    var id: Int
    var text: String?
    var date: Double
    var attachments: [Attachment]?
    var postSource: PostSource
    
    init(from repost: JSON) {
        self.postType = repost["post_type"].stringValue
        self.ownerId = repost["owner_id"].intValue
        self.id = repost["id"].intValue
        self.text = repost["text"].string
        self.date = repost["date"].doubleValue
        self.attachments = repost["attachments"].array?.compactMap { Attachment(from: $0) }
        self.postSource = PostSource(from: repost["post_source"])
    }
}

struct Copyright {
    var id: Int?
    var link: String
    var type: String
    var name: String
    
    init(from copyright: JSON) {
        self.id = copyright["id"].int
        self.link = copyright["link"].stringValue
        self.type = copyright["type"].stringValue
        self.name = copyright["name"].stringValue
    }
}
