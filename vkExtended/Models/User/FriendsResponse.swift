//
//  FriendsResponse.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 26.10.2020.
//

import Foundation
// MARK: - Response
struct FriendResponse: Decodable {
    var count: Int?
    var items: [FriendItem]?
}

// MARK: - Item
struct FriendItem: Decodable {
    let id: Int?
    let userId: Int?
    let firstName, lastName: String?
    let isClosed, canAccessClosed: Bool?
    let photo100: String?
    let onlineInfo: OnlineInfo?
    let online: Int?
    let trackCode, homeTown: String?
    let schools: [Schools]?
    let mutual: Mutual?
    let canWritePrivateMessage: Int
}

struct Mutual: Decodable {
    let count: Int?
}
