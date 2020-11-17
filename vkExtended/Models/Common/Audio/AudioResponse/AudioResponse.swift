//
//  AudioResponse.swift
//  VKExt
//
//  Created by programmist_NA on 13.07.2020.
//

import Foundation

struct AudioObject: Decodable {
    let response: AudioResponse
}

struct AudioResponse: Decodable {
    let items: [Item]
    let count: Int
}

struct Item: Decodable {
    let isExplicit: Bool
    let album: AudioAlbum?
    let artist: String?
    let date: Int
    let isLicensed: Bool?
    let title: String
    let url: String
    let storiesAllowed: Bool?
    let id: Int
    let isHq: Bool?
    let accessKey: String?
    let ownerId: Int
    let duration: Int?
    let subtitle: String?
    let genreId, lyricsId, noSearch: Int?
}

struct Artist: Decodable {
    let id, domain, name: String
}

public struct AudioAlbum: Decodable {
    let thumb: AudioThumb?
    let ownerId: Int
    let id: Int
    let title: String
}

public struct AudioThumb: Decodable {
    let width: Int
    let photo300, photo600, photo270, photo135: String?
    let photo34: String?
    let height: Int
    let photo68, photo1200: String?
}
