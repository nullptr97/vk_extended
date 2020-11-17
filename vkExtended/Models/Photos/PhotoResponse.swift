//
//  PhotoResponse.swift
//  VKExt
//
//  Created by programmist_NA on 17.07.2020.
//

import Foundation

struct PhotoResponse: Decodable {
    let count: Int
    var items: [PhotoItem]
    var hasNext: Bool {
        return items.count < count
    }
}

// MARK: - Item
struct PhotoItem: Decodable {
    let albumId, date, id, ownerId: Int?
    let hasTags: Bool?
    let postId: Int?
    let sizes: [Size]
    
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
            return Size(height: 0, url: "wrong image", type: "wrong image", width: 0)
        }
    }
    
    private func getMaxSize() -> Size {
        if let sizeX = sizes.first(where: { $0.type == "w" }) {
            return sizeX
        } else if let fallBackSize = sizes.last {
             return fallBackSize
        } else {
            return Size(height: 0, url: "wrong image", type: "wrong image", width: 0)
        }
    }
    
    let text: String?
    let likes: Likes?
    let reposts, comments: Comments?
    let canComment: Int?
    let tags: Comments?
    let lat, long: Double?
}

// MARK: - Comments
struct Comments: Decodable {
    let count: Int?
}

// MARK: - Likes
struct Likes: Decodable {
    let userLikes, count: Int?
}
