//
//  ProfileViewModel.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 26.10.2020.
//

import Foundation
import IGListKit

public enum FriendAction: String {
    case notFriend = "Добавить"
    case notFriendWithNoRequest = "Подписаться"
    case requestSend = "Заявка отправлена"
    case incomingRequest = "Подписан на Вас"
    case isFriend = "В друзьях"
    
    var image: String {
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
    
    var style: VKButtonStyle {
        switch self {
        case .isFriend, .requestSend:
            return .secondary
        default:
            return .primary
        }
    }
    
    var title: String {
        return rawValue
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
            case getProfile(userId: Int = currentUserId)
            case getFriends(userId: Int = currentUserId)
            case revealPostIds(postId: Int)
            case getNextBatch(userId: Int = currentUserId)
            case like(postId: Int, sourceId: Int, type: String)
            case unlike(postId: Int, sourceId: Int, type: String)
        }
    }
    struct Response {
        enum ResponseType {
            case presentProfile(profile: ProfileResponse?, photos: PhotoResponse?, friends: FriendResponse?)
            case presentProfileFriends(friends: FriendResponse)
            case presentProfileWall(wall: WallResponse, revealdedPostIds: [Int])
            case presentFooterLoader
            case presentFooterError(message: String)
        }
    }
    struct ViewModel {
        enum ViewModelData {
            case displayProfile(profileViewModel: ProfileViewModel, photosViewModel: PhotoViewModel, friendsViewModel: FriendViewModel)
            case displayProfileFriends(friendsViewModel: FriendViewModel)
            case displayProfileWall(wallViewModel: FeedViewModel)
            case displayFooterLoader
            case displayFooterError(message: String)
        }
    }
}

struct ProfileViewModel {
    class Cell: ProfileCellViewModel, ListDiffable {
        private var identifier: String = UUID().uuidString
        
        var imageStatusUrl: String?

        var verified: Int?
        var counters: Counters?
        var occupation: Occupation?
        var isCurrentProfile: Bool
        var friendActionType: FriendAction
        var type: ProfileActionType
        var id: Int
        var firstNameNom, lastNameNom: String
        var firstNameGen, lastNameGen: String
        var firstNameDat, lastNameDat: String
        var firstNameAcc, lastNameAcc: String
        var firstNameIns, lastNameIns: String
        var firstNameAbl, lastNameAbl: String
        var isClosed: Bool
        var canAccessClosed: Bool
        var canPost: Bool?
        var blacklisted: Bool?
        var deactivated: String?
        var sex: Int
        var screenName: String?
        var bdate: String?
        var lastSeen: Int
        var onlinePlatform: String
        var isOnline: Bool
        var isMobile: Bool
        var photo100: String
        var photoMaxOrig: String
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
        
        func getFullName(nameCase: NameCase, _ isShort: Bool = false) -> String {
            switch nameCase {
            case .nom:
                return isShort ? "\(firstNameNom)" : "\(firstNameNom) \(lastNameNom)"
            case .gen:
                return isShort ? "\(firstNameGen)" : "\(firstNameGen) \(lastNameGen)"
            case .dat:
                return isShort ? "\(firstNameDat)" : "\(firstNameDat) \(lastNameDat)"
            case .acc:
                return isShort ? "\(firstNameAcc)" : "\(firstNameAcc) \(lastNameAcc)"
            case .ins:
                return isShort ? "\(firstNameIns)" : "\(firstNameIns) \(lastNameIns)"
            case .abl:
                return isShort ? "\(firstNameAbl)" : "\(firstNameAbl) \(lastNameAbl)"
            }
        }
        
        func getOnline() -> String? {
            return isOnline ? "в сети \(onlinePlatform)" : StdService.instance.onlineTime(with: Date(timeIntervalSince1970: TimeInterval(lastSeen)), from: sex).string(from: Date(timeIntervalSince1970: TimeInterval(lastSeen)))
        }
        
        init(imageStatusUrl: String?,
             verified: Int?,
             counters: Counters?,
             occupation: Occupation?,
             isCurrentProfile: Bool,
             friendActionType: FriendAction,
             type: ProfileActionType,
             id: Int,
             firstNameNom: String, lastNameNom: String,
             firstNameGen: String, lastNameGen: String,
             firstNameDat: String, lastNameDat: String,
             firstNameAcc: String, lastNameAcc: String,
             firstNameIns: String, lastNameIns: String,
             firstNameAbl: String, lastNameAbl: String,
             isClosed: Bool, canAccessClosed: Bool, canPost: Bool?,
             blacklisted: Bool?,
             deactivated: String?,
             sex: Int,
             screenName: String?,
             bdate: String?,
             lastSeen: Int, onlinePlatform: String,
             isOnline: Bool, isMobile: Bool,
             photo100: String, photoMaxOrig: String,
             status: String?,
             friendsCount: Int?, followersCount: Int?,
             school: String?, work: String?, city: String?,
             relation: RelationType?,
             schools: [Schools], universities: [Universities],
             contacts: Contacts?, connections: Connections?,
             personalInfo: [(String, Optional<String>)]?) {
            self.imageStatusUrl = imageStatusUrl
            self.verified = verified
            self.counters = counters
            self.occupation = occupation
            self.isCurrentProfile = isCurrentProfile
            self.friendActionType = friendActionType
            self.type = type
            self.id = id
            
            self.firstNameNom = firstNameNom
            self.lastNameNom = lastNameNom
            self.firstNameGen = firstNameGen
            self.lastNameGen = lastNameGen
            self.firstNameDat = firstNameDat
            self.lastNameDat = lastNameDat
            self.firstNameAcc = firstNameAcc
            self.lastNameAcc = lastNameAcc
            self.firstNameIns = firstNameIns
            self.lastNameIns = lastNameIns
            self.firstNameAbl = firstNameAbl
            self.lastNameAbl = lastNameAbl
            
            self.isClosed = isClosed
            self.canAccessClosed = canAccessClosed
            self.canPost = canPost
            self.blacklisted = blacklisted
            self.deactivated = deactivated
            self.sex = sex
            self.screenName = screenName
            self.bdate = bdate
            self.lastSeen = lastSeen
            self.onlinePlatform = onlinePlatform
            self.isOnline = isOnline
            self.isMobile = isMobile
            self.photo100 = photo100
            self.photoMaxOrig = photoMaxOrig
            self.status = status
            self.friendsCount = friendsCount
            self.followersCount = followersCount
            self.school = school
            self.work = work
            self.city = city
            self.relation = relation
            self.schools = schools
            self.universities = universities
            self.contacts = contacts
            self.connections = connections
            self.personalInfo = personalInfo
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

    var cell: Cell?
    let footerTitle: String?
}

protocol ProfileCellViewModel {
    var id: Int { get }
    
    var imageStatusUrl: String? { get }
    
    var firstNameNom: String { get }
    var firstNameGen: String { get }
    var firstNameDat: String { get }
    var firstNameAcc: String { get }
    var firstNameIns: String { get }
    var firstNameAbl: String { get }
    
    var lastNameNom: String { get }
    var lastNameGen: String { get }
    var lastNameDat: String { get }
    var lastNameAcc: String { get }
    var lastNameIns: String { get }
    var lastNameAbl: String { get }
    
    var isClosed: Bool { get }
    var canAccessClosed: Bool { get }
    var canPost: Bool? { get }
    var blacklisted: Bool? { get }
    var deactivated: String? { get }
    var sex: Int { get }
    var screenName: String? { get }
    var bdate: String? { get }
    var lastSeen: Int { get }
    var onlinePlatform: String { get }
    var isOnline: Bool { get }
    var isMobile: Bool { get }
    var photo100: String { get }
    var photoMaxOrig: String { get }
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
    
    func getFullName(nameCase: NameCase, _ isShort: Bool) -> String
}

enum ProfileActionType {
    case actionFriendWithMessage
    case actionFriend
}
