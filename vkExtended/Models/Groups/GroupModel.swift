//
//  GroupModel.swift
//  VKExt
//
//  Created by Ярослав Стрельников on 31.08.2020.
//

import Foundation
import SwiftyJSON

// MARK: - Response
struct GroupResponse: Decodable {
    let count: Int
    var items: [GroupItem]
    
    init(from response: JSON) {
        self.count = response["count"].intValue
        self.items = response["items"].arrayValue.map { GroupItem(from: $0) }
    }
}

// MARK: - Item
struct GroupItem: Decodable {
    let id: Int
    let name: String
    let screenName: String
    let isClosed: Int
    let type: String
    let isAdmin, adminLevel, isMember, isAdvertiser: Int
    let activity: String
    let photo50, photo100, photo200: String
    let verified: Int
    
    init(from item: JSON) {
        self.name = item["name"].stringValue
        self.screenName = item["screen_name"].stringValue
        self.id = item["id"].intValue
        self.isClosed = item["is_closed"].intValue
        self.type = item["type"].stringValue
        self.isAdmin = item["is_admin"].intValue
        self.isMember = item["name"].intValue
        self.isAdvertiser = item["images"].intValue
        self.adminLevel = item["admin_level"].intValue
        self.activity = item["activity"].stringValue
        self.photo50 = item["photo_50"].stringValue
        self.photo100 = item["photo_100"].stringValue
        self.photo200 = item["photo_200"].stringValue
        self.verified = item["verified"].intValue
    }
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
