//
//  FriendViewModel.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 26.10.2020.
//

import Foundation

enum FriendModel {
    struct Request {
        enum RequestType {
            case getFriend(userId: Int = Constants.currentUserId)
            case getFollowers(userId: Int = Constants.currentUserId)
            case getNextFriends(userId: Int = Constants.currentUserId)
            case getNextFollowers(userId: Int = Constants.currentUserId)
            case getRequests
            case delete(userId: Int)
        }
    }
    struct Response {
        enum ResponseType {
            case presentFriend(response: FriendResponse)
            case presentFooterLoader
            case presentFooterError(message: String)
            case delete(index: Int)
        }
    }
    struct ViewModel {
        enum ViewModelData {
            case displayFriend(friendViewModel: FriendViewModel)
            case displayFooterLoader
            case displayFooterError(message: String)
            case delete(index: Int)
        }
    }
}

struct FriendViewModel {
    struct Cell: FriendCellViewModel {
        var canWriteMessage: Int
        var lastSeen: Int
        var onlinePlatform: String
        var id: Int?
        var firstName: String?
        var lastName: String?
        var isClosed: Bool?
        var isOnline: Bool?
        var isMobile: Bool?
        var photo100: String?
        var school: String?
        var homeTown: String?
        var mutualCount: Int?
    }
    
    var cell: [Cell]
    let footerTitle: String?
}

protocol FriendCellViewModel {
    var id: Int? { get }
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
}

enum Platforms: String {
    case android = "Android"
    case iPhone = "iPhone"
    case iPad = "iPad"
    case windows = "Windows Phone"
    case windowsD = "Windows"
    case kate = "Kate Mobile"
    case vkMp3 = "VK MP3 Mod"
    case lynt = "Lynt"
    case instagram = "Instagram"
    case another = "мобильного"
    
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
        default:
            return .another
        }
    }
}
