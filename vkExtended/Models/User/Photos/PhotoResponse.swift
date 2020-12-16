//
//  PhotoResponse.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 28.10.2020.
//

import Foundation
import SwiftyJSON

struct PhotoResponse: Decodable {
    let count: Int
    let items: [PhotoItem]
    
    init(from response: JSON) {
        self.count = response["count"].intValue
        self.items = response["items"].arrayValue.compactMap({ PhotoItem(from: $0) })
    }
}

// MARK: - Item
struct PhotoItem: Decodable {
    let albumId, date, id, ownerId: Int
    let hasTags: Bool?
    let postId: Int?
    let sizes: [Size]
    let text: String?
    let likes: CountableLikeItem?
    let reposts: CountableShareItem?
    let comments: CountableCommentItem?
    let canComment: Int?
    let tags: Comments?
    let lat, long: Double?
    
    init(from item: JSON) {
        self.albumId = item["album_id"].intValue
        self.date = item["date"].intValue
        self.id = item["id"].intValue
        self.ownerId = item["owner_id"].intValue
        self.hasTags = item["has_tags"].boolValue
        self.postId = item["post_id"].int
        self.sizes = item["sizes"].arrayValue.compactMap { Size(size: $0) }
        self.text = item["text"].string
        self.likes = CountableLikeItem(from: item["likes"])
        self.reposts = CountableShareItem(from: item["comments"])
        self.comments = CountableCommentItem(from: item["reposts"])
        self.canComment = item["can_comment"].int
        self.tags = Comments(count: item["tags"]["count"].int)
        self.lat = item["lat"].double
        self.long = item["long"].double
    }
    
    var height: Int {
         return getPropperSize().height ?? 1
    }
    
    var width: Int {
        return getPropperSize().width ?? 1
    }
    
    var srcBIG: String {
         return getPropperSize().url!
    }
    
    var srcMax: String {
         return getMaxSize().url!
    }
    
    private func getPropperSize() -> Size {
        if let sizeX = sizes.first(where: { $0.type == "q" }) {
            return sizeX
        } else if let fallBackSize = sizes.last {
             return fallBackSize
        } else {
            return Size(size: JSON())
        }
    }
    
    private func getMaxSize() -> Size {
        if let sizeX = sizes.first(where: { $0.type == "w" }) {
            return sizeX
        } else if let fallBackSize = sizes.last {
             return fallBackSize
        } else {
            return Size(size: JSON())
        }
    }
}

// MARK: - Comments
struct Comments: Decodable {
    let count: Int?
}

// MARK: - Likes
struct Likes: Decodable {
    let userLikes, count: Int?
}
