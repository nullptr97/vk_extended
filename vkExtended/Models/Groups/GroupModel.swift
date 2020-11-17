//
//  GroupModel.swift
//  VKExt
//
//  Created by Ярослав Стрельников on 31.08.2020.
//

import Foundation
// MARK: - Response
struct GroupResponse: Decodable {
    let count: Int
    var items: [GroupItem]
}

// MARK: - Item
struct GroupItem: Decodable {
    let id: Int
    let name: String
    let screenName: String?
    let isClosed: Int
    let type: String
    let isAdmin, adminLevel, isMember, isAdvertiser: Int?
    let activity: String?
    let photo50, photo100, photo200: String
    let verified: Int?
}

// MARK: - GroupMembers
struct GroupMembersResponse: Decodable {
    let count: Int
    var items: [GroupMemberItem]
}

// MARK: - GroupMemberItem
struct GroupMemberItem: Decodable {
    let id: Int
    let firstName: String
    let lastName: String
    let sex: Int
    let photo100: String
    let canWritePrivateMessage: Int
}
