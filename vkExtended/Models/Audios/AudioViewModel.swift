//
//  AudioViewModel.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 17.11.2020.
//

import Foundation
import UIKit
import SwiftyJSON

public struct AudioViewModel {
    var id: Int
    var ownerId: Int
    var artist: String
    var title: String
    var duration: Int
    var url: String
    var lyricsId: Int?
    var albumId: Int?
    var genreId: Int?
    var date: Int
    var noSearch: Int
    var isHq: Int
    var isExplicit: Bool
    var album: AlbumViewModel
    
    init(audio: JSON) {
        self.id = audio["id"].intValue
        self.ownerId = audio["owner_id"].intValue
        self.artist = audio["artist"].stringValue
        self.title = audio["title"].stringValue
        self.duration = audio["duration"].intValue
        self.url = audio["url"].stringValue
        self.lyricsId = audio["lyrics_id"].int
        self.albumId = audio["album_id"].int
        self.genreId = audio["genre_id"].int
        self.date = audio["date"].intValue
        self.noSearch = audio["no_search"].intValue
        self.isHq = audio["is_hq"].intValue
        self.isExplicit = audio["is_explicit"].boolValue
        self.album = AlbumViewModel(album: audio["album"])
    }
}
struct AlbumViewModel {
    var accessKey: String
    var ownerId: Int
    var id: Int
    var title: String
    var thumb: ThumbViewModel
    
    var imageUrl: String {
        thumb.getImage()
    }
    
    init(album: JSON) {
        self.id = album["id"].intValue
        self.ownerId = album["owner_id"].intValue
        self.title = album["title"].stringValue
        self.accessKey = album["access_key"].stringValue
        self.thumb = ThumbViewModel(thumb: album["thumb"])
    }
}
struct ThumbViewModel {
    var photo34, photo68, photo135, photo270, photo300, photo600, photo1200: String
    var width: Int
    var height: Int
    
    var photosUrl: [String] {
        return [photo34, photo68, photo135, photo270, photo300, photo600, photo1200]
    }
    
    init(thumb: JSON) {
        self.width = thumb["width"].intValue
        self.height = thumb["height"].intValue
        self.photo34 = thumb["photo_34"].stringValue
        self.photo68 = thumb["photo_68"].stringValue
        self.photo135 = thumb["photo_135"].stringValue
        self.photo270 = thumb["photo_270"].stringValue
        self.photo300 = thumb["photo_300"].stringValue
        self.photo600 = thumb["photo_600"].stringValue
        self.photo1200 = thumb["photo_1200"].stringValue
    }
    
    func getImage() -> String {
        var imageUrl: String = ""
        
        for url in photosUrl {
            if !url.isEmpty {
                imageUrl = url
            }
        }
        
        return imageUrl
    }
}
