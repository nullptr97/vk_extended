//
//  Audio.swift
//  VKExt
//
//  Created by programmist_NA on 23.05.2020.
//

import Foundation
import SwiftyJSON
import UIKit
import RealmSwift
import Kingfisher

struct Audio: Decodable {
    let title: String
        let id: Int
    let date: Int
    let url: String
    let artist: String
    let ownerId: Int
    let duration: Int
    let isExplicit: Bool?
    let isLicensed: Bool?
    
    init(audio: JSON) {
        self.title = audio["title"].stringValue
        self.id = audio["id"].intValue
        self.date = audio["date"].intValue
        self.url = audio["url"].stringValue
        self.artist = audio["artist"].stringValue
        self.ownerId = audio["owner_id"].intValue
        self.duration = audio["duration"].intValue
        self.isExplicit = audio["is_explicit"].bool
        self.isLicensed = audio["is_licensed"].bool
    }
    
    var isDownloaded: Bool {
        get {
            let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(URL(string: url)!.lastPathComponent)

            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                return true
            } else {
                return false
            }
        }
    }
}
struct Album: Decodable {
    let accessKey: String
    let ownerId: Int
    let title: String
    let id: Int
    let thumb: Thumb
    
    init(album: JSON) {
        self.accessKey = album["access_key"].stringValue
        self.ownerId = album["owner_id"].intValue
        self.title = album["title"].stringValue
        self.id = album["id"].intValue
        self.thumb = Thumb(thumb: album["thumb"])
    }
}
struct Thumb: Decodable {
    let height: Int
    let width: Int
    let photo34: String
    let photo68: String
    let photo135: String
    let photo270: String
    let photo300: String
    let photo600: String
    let photo1200: String
    
    init(thumb: JSON) {
        self.height = thumb["height"].intValue
        self.width = thumb["width"].intValue
        self.photo34 = thumb["photo_34"].stringValue
        self.photo68 = thumb["photo_68"].stringValue
        self.photo135 = thumb["photo_135"].stringValue
        self.photo270 = thumb["photo_270"].stringValue
        self.photo300 = thumb["photo_300"].stringValue
        self.photo600 = thumb["photo_600"].stringValue
        self.photo1200 = thumb["photo_1200"].stringValue
    }
    
    var artwork: UIImage? {
        guard let url = URL(string: photo135) else { return nil }
        guard let image = UIImage(data: try! Data(contentsOf: url)) else { return nil }
        return image
    }
}

class SavedAudio: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var id: Int = 0
    @objc dynamic var date: Int = 0
    @objc dynamic var url: String = ""
    @objc dynamic var artist: String = ""
    @objc dynamic var ownerId: Int = 0
    @objc dynamic var duration: Int = 0
    @objc dynamic var path: String = ""
    
    convenience init(audio: Audio, at path: String) {
        self.init()
        self.title = audio.title
        self.id = audio.id
        self.date = audio.date
        self.url = audio.url
        self.artist = audio.artist
        self.ownerId = audio.ownerId
        self.duration = audio.duration
        self.path = path
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
