//
//  ProfileViewModels.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 25.11.2020.
//

import Foundation
import IGListKit

enum AccessDeniedType {
    case banned
    case deleted
    case closed
}

class ProfileCommonInfoViewModel: ListDiffable {
    private var identifier: String = UUID().uuidString
    
    var imageStatusUrl: String?
    
    var id: Int
    var friendActionType: FriendAction
    var type: ProfileActionType
    var status: String?
    var name: String
    var lastSeen: Int
    var onlinePlatform: String
    var isOnline: Bool
    var isMobile: Bool
    var photo100: String
    var photoMax: String
    var counters: Counters?
    var deactivated: Bool
    
    init(id: Int, imageStatusUrl: String?, friendActionType: FriendAction, type: ProfileActionType, status: String?, name: String, lastSeen: Int, onlinePlatform: String, isOnline: Bool, isMobile: Bool, photo100: String, photoMax: String, counters: Counters?, deactivated: Bool) {
        self.id = id
        self.imageStatusUrl = imageStatusUrl
        self.friendActionType = friendActionType
        self.type = type
        self.status = status
        self.name = name
        self.lastSeen = lastSeen
        self.onlinePlatform = onlinePlatform
        self.isOnline = isOnline
        self.isMobile = isMobile
        self.photo100 = photo100
        self.photoMax = photoMax
        self.counters = counters
        self.deactivated = deactivated
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? ProfileCommonInfoViewModel else {
            return false
        }
        
        return self.identifier == object.identifier
    }
}

class BannedInfoViewModel: ListDiffable {
    private var identifier: String = UUID().uuidString
    
    var causeText: String
    var banType: AccessDeniedType
    
    init(causeText: String, banType: AccessDeniedType) {
        self.causeText = causeText
        self.banType = banType
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? BannedInfoViewModel else {
            return false
        }
        
        return self.identifier == object.identifier
    }
}

class CloseInfoViewModel: ListDiffable {
    private var identifier: String = UUID().uuidString
    
    var causeText: String
    var causeRecomendationText: String
    var banType: AccessDeniedType
    
    init(causeText: String, causeRecomendationText: String, banType: AccessDeniedType) {
        self.causeText = causeText
        self.causeRecomendationText = causeRecomendationText
        self.banType = banType
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? CloseInfoViewModel else {
            return false
        }
        
        return self.identifier == object.identifier
    }
}

class ProfilePhotosViewModel: ListDiffable {
    private var identifier: String = UUID().uuidString
    
    var cell: [PhotoViewModel.Cell]
    var count: Int
    
    init(cell: [PhotoViewModel.Cell], count: Int = 0) {
        self.cell = cell
        self.count = count
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? ProfilePhotosViewModel else {
            return false
        }
        
        return self.identifier == object.identifier
    }
}

class ProfileFriendsViewModel: ListDiffable {
    private var identifier: String = UUID().uuidString
    
    var cell: [FriendViewModel.Cell]
    var count: Int
    
    init(cell: [FriendViewModel.Cell], count: Int = 0) {
        self.cell = cell
        self.count = count
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? ProfileFriendsViewModel else {
            return false
        }
        
        return self.identifier == object.identifier
    }
}
