//
//  FriendViewModel.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 26.10.2020.
//

import Foundation
import IGListKit

enum FriendModel {
    struct Request {
        enum RequestType {
            case getFriend(userId: Int = currentUserId)
            case getFollowers(userId: Int = currentUserId)
            case getNextFriends(userId: Int = currentUserId)
            case getNextFollowers(userId: Int = currentUserId)
            case getRequests
            case getPossible
            case delete(userId: Int)
        }
    }
    struct Response {
        enum ResponseType {
            case presentFriend(response: FriendResponse)
            case presentSuggestions(response: FriendResponse)
            case presentFooterLoader
            case presentFooterError(message: String)
            case delete(index: Int)
        }
    }
    struct ViewModel {
        enum ViewModelData {
            case displayFriend(friendViewModel: FriendViewModel)
            case displayAllFriend(importantFriendViewModel: FriendViewModel, friendViewModel: FriendViewModel)
            case displaySuggestions(friendViewModel: FriendViewModel)
            case displayFooterLoader
            case displayFooterError(message: String)
            case delete(index: Int)
        }
    }
}

class FriendViewModel: ListDiffable {
    private var identifier: String = UUID().uuidString
    var count: Int

    class Cell: FriendCellViewModel, ListDiffable {
        private var identifier: String = UUID().uuidString

        var canWriteMessage: Int
        var lastSeen: Int
        var onlinePlatform: String
        var id: Int?
        var imageStatusUrl: String?
        var firstName: String?
        var lastName: String?
        var isClosed: Bool?
        var isOnline: Bool?
        var isMobile: Bool?
        var photo100: String?
        var school: String?
        var homeTown: String?
        var mutualCount: Int?
        var deactivated: String?
        var sex: Int
        var screenName: String?
        var bdate: String?
        
        var fullName: String {
            return (firstName ?? "") + " " + (lastName ?? "")
        }
        
        init(canWriteMessage: Int,
             imageStatusUrl: String?,
             lastSeen: Int,
             verified: Int?,
             onlinePlatform: String,
             id: Int,
             firstName: String, lastName: String,
             isClosed: Bool,
             deactivated: String?,
             sex: Int,
             screenName: String?,
             bdate: String?,
             isOnline: Bool, isMobile: Bool,
             photo100: String, city: String?,
             school: String?) {
            self.canWriteMessage = canWriteMessage
            self.lastSeen = lastSeen
            self.onlinePlatform = onlinePlatform
            
            self.imageStatusUrl = imageStatusUrl
            self.id = id
            
            self.firstName = firstName
            self.lastName = lastName
            
            self.isClosed = isClosed
            self.deactivated = deactivated
            self.sex = sex
            self.screenName = screenName
            self.bdate = bdate
            self.isOnline = isOnline
            self.isMobile = isMobile
            self.photo100 = photo100
            self.school = school
            self.homeTown = city
        }
        
        func diffIdentifier() -> NSObjectProtocol {
            return identifier as NSString
        }
        
        func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
            guard let object = object as? Cell else {
                return false
            }
            
            return self.identifier == object.identifier
        }
    }
    
    init(cell: [Cell], footerTitle: String?, count: Int) {
        self.cell = cell
        self.footerTitle = footerTitle
        self.count = count
    }
    
    var cell: [Cell]
    let footerTitle: String?
    
    func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? FriendViewModel else {
            return false
        }
        
        return self.identifier == object.identifier
    }
    
    func sort() -> FriendViewModel {
        guard cell.count > 5 else { return self }
        var sortedIndex = 0
        while sortedIndex < 5 {
            let removeCell = cell.remove(at: 0)
            cell.insert(removeCell, at: cell.count)
            sortedIndex += 1
        }
        return self
    }
}

protocol FriendCellViewModel {
    var id: Int? { get }
    var imageStatusUrl: String? { get }
    var firstName: String? { get }
    var lastName: String? { get }
    var isClosed: Bool? { get }
    var isOnline: Bool? { get }
    var isMobile: Bool? { get }
    var onlinePlatform: String { get }
    var lastSeen: Int { get }
    var photo100: String? { get }
    var school: String? { get }
    var homeTown: String? { get }
    var mutualCount: Int? { get }
    var canWriteMessage: Int { get }
    var deactivated: String? { get }
    var sex: Int { get }
    var screenName: String? { get }
    var bdate: String? { get }
}

enum Platforms: String {
    case android = "c Android"
    case iPhone = "c iPhone"
    case iPad = "c iPad"
    case windows = "c Windows Phone"
    case windowsD = "c Windows"
    case kate = "c Kate Mobile"
    case vkMp3 = "c VK MP3 Mod"
    case lynt = "c Lynt"
    case instagram = "c Instagram"
    case vfeed = "c VFeed"
    case another = "c мобильного"
    case pc = ""
    
    static func getPlatform(by platformCode: Int) -> Self {
        switch platformCode {
        case 2274003:
            return .android
        case 3140623:
            return .iPhone
        case 3682744:
            return .iPad
        case 3697615:
            return .windowsD
        case 3502557:
            return .windows
        case 2685278:
            return .kate
        case 4996844:
            return .vkMp3
        case 3469984:
            return .lynt
        case 3698024:
            return .instagram
        case 5316500:
            return .vfeed
        case 0:
            return .pc
        default:
            return .another
        }
    }
}
