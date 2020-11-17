//
//  Friend.swift
//  VKExt
//
//  Created by programmist_NA on 29.05.2020.
//

import Foundation
import SwiftyJSON
import RealmSwift

class FriendDataModel: Object {
    var id: Int = 0
    var name: String = ""
    var status: String? = ""
    var canWriteMessage: Int = 0
    var shortName: String = ""
    var sex: Int = 0
    var friendStatus: Int = 0
    var photo100: String = ""
    // var onlineInfo: OnlineInfo?
    var lastSeenTime: Int = 0
    var homeTown: String? = ""
    var deactivated: String? = ""
    var schools: String? = ""
    
    convenience init(friend: JSON) {
        self.init()
        self.id = friend["id"].intValue
        self.name = "\(friend["first_name"].stringValue) \(friend["last_name"].stringValue)"
        self.status = friend["status"].stringValue
        self.canWriteMessage = friend["can_write_private_message"].intValue
        self.shortName = friend["screen_name"].stringValue
        self.sex = friend["sex"].intValue
        self.friendStatus = friend["friend_status"].intValue
        self.photo100 = friend["photo_100"].stringValue
        // self.onlineInfo = OnlineInfo(info: friend["online_info"])
        self.lastSeenTime = friend["last_seen"]["time"].intValue
        self.schools = friend["occupation"]["name"].string
        self.homeTown = friend["city"]["title"].string
        self.deactivated = friend["deactivated"].string
    }
}
