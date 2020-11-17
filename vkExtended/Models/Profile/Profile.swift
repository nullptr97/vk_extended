//
//  Profile.swift
//  VKExt
//
//  Created by programmist_NA on 27.05.2020.
//

import Foundation

import SwiftyJSON
import RealmSwift

struct ProfileHeader {
    let id: Int
    let name: String
    let status: String?
    let isFriend: Int
    let canWriteMessage: Int
    let shortName: String
    let sex: Int
    let friendStatus: Int
    let photo100: String
    let lastSeenTime: Int
    
    init(profile: JSON) {
        self.id = profile["id"].intValue
        self.name = "\(profile["first_name"].stringValue) \(profile["last_name"].stringValue)"
        self.status = profile["status"].stringValue
        self.isFriend = profile["isFriend"].intValue
        self.canWriteMessage = profile["can_write_private_message"].intValue
        self.shortName = profile["screen_name"].stringValue
        self.sex = profile["sex"].intValue
        self.friendStatus = profile["friend_status"].intValue
        self.photo100 = profile["photo_100"].stringValue
        // self.onlineInfo = OnlineInfo(info: profile["online_info"])
        self.lastSeenTime = profile["last_seen"]["time"].intValue
    }
    
    var isCurrentProfile: Bool {
        get {
            return id == Constants.currentUserId
        }
    }
}

class PrimitiveUser: Object {
    @objc dynamic var id: Int = Constants.currentUserId
    @objc dynamic var photo100: String = ""
    @objc dynamic var firstName: String = ""
    @objc dynamic var lastName: String = ""
    
    convenience init(photo100: String, firstName: String, lastName: String) {
        self.init()
        self.photo100 = photo100
        self.firstName = firstName
        self.lastName = lastName
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
