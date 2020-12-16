//
//  FriendsResponse.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 26.10.2020.
//

import Foundation
import SwiftyJSON
// MARK: - Response
struct FriendResponse: Decodable {
    var count: Int?
    var items: [FriendItem]
    
    init(from response: JSON) {
        self.count = response["count"].intValue
        self.items = response["items"].arrayValue.compactMap { FriendItem(from: $0) }
    }
}

// MARK: - Item
struct FriendItem: Decodable {
    let id: Int
    let imageStatusUrl: String?
    let firstName, lastName: String
    let isClosed, canAccessClosed: Bool
    let photo100: String
    let onlineInfo: OnlineInfo
    let homeTown: String
    let schools: [Schools]
    let mutual: Mutual
    let canWritePrivateMessage: Int
    let deactivated: String?
    let sex: Int
    let screenName: String?
    let bdate: String?
    let verified: Int
    
    init(from item: JSON) {
        self.firstName = item["first_name"].stringValue
        self.lastName = item["last_name"].stringValue
        
        self.imageStatusUrl = item["image_status"]["images"].arrayValue.first?["url"].string
        
        self.id = item["id"].intValue
        self.canAccessClosed = item["can_access_closed"].boolValue
        self.isClosed = item["is_closed"].boolValue
        self.photo100 = item["photo_100"].stringValue
        self.onlineInfo = OnlineInfo(onlineInfo: item["online_info"])
        self.schools = item["schools"].arrayValue.compactMap { Schools(schools: $0) }
        self.homeTown = item["home_town"].stringValue
        self.mutual = Mutual(from: item["mutual"])
        self.canWritePrivateMessage = item["can_write_private_message"].intValue
        self.deactivated = item["deactivated"].string
        self.sex = item["sex"].intValue
        self.screenName = item["screen_name"].string
        self.bdate = item["bdate"].string
        self.verified = item["verified"].intValue
    }
    
    func getVerification() -> Bool {
        return verified.boolValue || Constants.verifyingProfile(from: id)
    }
}

struct Mutual: Decodable {
    let count: Int
    
    init(from mutual: JSON) {
        self.count = mutual["count"].intValue
    }
}
