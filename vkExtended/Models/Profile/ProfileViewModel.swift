//
//  ProfileViewModel.swift
//  VKExt
//
//  Created by programmist_NA on 15.07.2020.
//

import Foundation
import UIKit

public enum FriendAction: String {
    case notFriend = "Добавить"
    case notFriendWithNoRequest = "Подписаться"
    case requestSend = "Заявка отправлена"
    case incomingRequest = "Подписан на Вас"
    case isFriend = "У Вас в друзьях"
    
    func setImage() -> String {
        switch self {
        case .notFriend, .notFriendWithNoRequest:
            return "user_add_outline_28"
        case .requestSend:
            return "user_outgoing_outline_28"
        case .incomingRequest:
            return "user_incoming_outline_28"
        case .isFriend:
            return "users_outline_28"
        }
    }
}

enum RelationType: String {
    case notMarriedF = "Не замужем"
    case notMarriedM = "Не женат"
    case haveAFriend = "Есть друг"
    case haveAGirlFriend = "Есть подруга"
    case engagedF = "Помолвена"
    case engagedM = "Помолвен"
    case marriedF = "Замужем"
    case marriedM = "Женат"
    case complicated = "Все сложно"
    case activelyLooking = "В активном поиске"
    case inLoveF = "Влюблена"
    case inLoveM = "Влюблен"
    case inACivilMarriage = "В гражданском браке"
    case none
    
    static func getRelationType(with sex: Int, relation: Int) -> Self {
        switch relation {
        case 0:
            return .none
        case 1:
            return sex == 1 ? .notMarriedF : .notMarriedM
        case 2:
            return sex == 1 ? .haveAFriend : .haveAGirlFriend
        case 3:
            return sex == 1 ? .engagedF : .engagedM
        case 4:
            return sex == 1 ? .marriedF : .marriedM
        case 5:
            return .complicated
        case 6:
            return .activelyLooking
        case 7:
            return sex == 1 ? .inLoveF : .inLoveM
        case 8:
            return .inACivilMarriage
        default:
            return .none
        }
    }
}

enum ProfileModel {
    struct Request {
        enum RequestType {
            case getProfileWall(userId: Int = Constants.currentUserId)
            case getPhotos(ownerId: Int = Constants.currentUserId)
            case getAll(userId: Int = Constants.currentUserId)
            case getGifts(userId: Int = Constants.currentUserId)
            case revealPostIds(postId: Int)
            case getNextBatch(userId: Int = Constants.currentUserId)
            case getNextPhotosBatch(ownerId: Int = Constants.currentUserId)
            case like(postId: Int, sourceId: Int, type: String)
            case unlike(postId: Int, sourceId: Int, type: String)
        }
    }
    struct Response {
        enum ResponseType {
            case presentAll(profile: ProfileResponse, photos: PhotoResponse?, wall: WallResponse?, revealdedPostIds: [Int]?)
            case presentGifts(gifts: GiftsResponse)
            case presentProfileWall(wall: WallResponse, revealdedPostIds: [Int])
            case presentPhotos(photos: PhotoResponse)
            case presentFooterLoader
            case presentFooterError(message: String)
        }
    }
    struct ViewModel {
        enum ViewModelData {
            case displayAll(profileViewModel: ProfileViewModel, photosViewModel: PhotoViewModel, wallViewModel: FeedViewModel)
            case displayGifts(giftViewModel: GiftViewModel)
            case displayWall(wallViewModel: FeedViewModel)
            case displayPhotos(photosViewModel: PhotosViewModel)
            case displayFooterLoader
            case displayFooterError(message: String)
        }
    }
}

struct ProfileViewModel {
    struct Cell: ProfileCellViewModel {
        var verified: Int?
        var counters: Counters?
        var occupation: Occupation?
        var isCurrentProfile: Bool
        var friendActionType: FriendAction
        var type: ProfileActionType
        var id: Int?
        var firstName: String?
        var lastName: String?
        var isClosed: Bool?
        var canAccessClosed: Bool?
        var canPost: Bool?
        var blacklisted: Bool?
        var deactivated: String?
        var sex: Int?
        var screenName: String?
        var bdate: String?
        var isOnline: Bool?
        var isMobile: Bool?
        var onlineApp: Int?
        var photo100: String?
        var photoMaxOrig: String?
        var status: String?
        var friendsCount: Int?
        var followersCount: Int?
        var school: String?
        var work: String?
        var city: String?
        var relation: RelationType?
        var schools: [Schools]
        var universities: [Universities]
        var contacts: Contacts?
        var connections: Connections?
        var personalInfo: [(String, Optional<String>)]?
    }

    var cell: Cell?
    let footerTitle: String?
}

protocol ProfileCellViewModel {
    var id: Int? { get }
    var firstName: String? { get }
    var lastName: String? { get }
    var isClosed: Bool? { get }
    var canAccessClosed: Bool? { get }
    var canPost: Bool? { get }
    var blacklisted: Bool? { get }
    var deactivated: String? { get }
    var sex: Int? { get }
    var screenName: String? { get }
    var bdate: String? { get }
    var isOnline: Bool? { get }
    var isMobile: Bool? { get }
    var onlineApp: Int? { get }
    var photo100: String? { get }
    var photoMaxOrig: String? { get }
    var status: String? { get }
    var verified: Int? { get }
    var counters: Counters? { get }
    var occupation: Occupation? { get }
    // ---
    var friendsCount: Int? { get }
    var followersCount: Int? { get }
    var school: String? { get }
    var work: String? { get }
    var city: String? { get }
    var type: ProfileActionType { get }
    var friendActionType: FriendAction { get }
    var isCurrentProfile: Bool { get }
    var relation: RelationType? { get }
    // ---
    var schools: [Schools] { get }
    var universities: [Universities] { get }
    var contacts: Contacts? { get }
    var connections: Connections? { get }
    var personalInfo: [(String, Optional<String>)]? { get }
}

enum ApplicationOnline: String {
    case vkExtended = "VK Extended"
    case vkMe = "VK Me"
    case android = "Android"
    case iPhone = "iPhone"
    case unknown = "Unknown"
    
    static func getApp(by appId: Int) -> Self {
        switch appId {
        case 7288225:
            return .vkExtended
        case 6146827:
            return .vkMe
        case 3140623:
            return .iPhone
        case 2274003:
            return .android
        default:
            return .unknown
        }
    }
}

enum ProfileActionType {
    case actionFriendWithMessage
    case actionFriend
}

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
            case presentSharedFriends(friendsResponse: FriendResponse, onlineFriendsResponse: OnlineFriendResponse, mutualFriendsResponse: [Int])
            case presentFooterLoader
            case presentFooterError(message: String)
            case delete(index: Int)
        }
    }
    struct ViewModel {
        enum ViewModelData {
            case displayFriend(friendViewModel: FriendViewModel)
            case displaySharedFriends(friendViewModel: FriendViewModel, onlineFriends: OnlineFriendViewModel, mutualFriends: [Int])
            case displayFooterLoader
            case displayFooterError(message: String)
            case delete(index: Int)
        }
    }
}

struct OnlineFriendViewModel {
    struct Object {
        var online: [Int]
        var onlineMobile: [Int]
    }
    var object: Object
}

struct FriendViewModel {
    struct Cell: FriendCellViewModel {
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
    var photo100: String? { get }
    var school: String? { get }
    var homeTown: String? { get }
    var mutualCount: Int? { get }
}

struct GiftViewModel {
    struct Cell: GiftCellViewModel {
        var id: Int
        var fromId: Int
        var message: String
        var date: Int
        var privacy: Int?
        var giftHash: String
        var giftId: Int
        var thubm256: String
    }

    var cells: [Cell]?
}

protocol GiftCellViewModel {
    var id: Int { get }
    var fromId: Int { get }
    var message: String { get }
    var date: Int { get }
    var privacy: Int? { get }
    var giftHash: String { get }
    var giftId: Int { get }
    var thubm256: String { get }
}
