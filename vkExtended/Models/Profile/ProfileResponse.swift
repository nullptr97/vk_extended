//
//  ProfileResponse.swift
//  VKExt
//
//  Created by programmist_NA on 15.07.2020.
//

import Foundation
import SwiftyJSON

struct UserGetResponse: Decodable {
    var response: [ProfileResponse]
}

enum PersonalRelationType: String {
    case negativeSharply = "Резко негативное"
    case negative = "Негативное"
    case compromise = "Компромиссное"
    case neutral = "Нейтральное"
    case positive = "Положительное"
    case none
    
    static func get(by number: Int?) -> Self {
        if number == 1 {
            return .negativeSharply
        } else if number == 2 {
            return .negative
        } else if number == 3 {
            return .compromise
        } else if number == 4 {
            return .neutral
        } else if number == 5 {
            return .positive
        } else {
            return .none
        }
    }
}

enum PersonalLifeMainType: String {
    case familyAndChildren = "Семья и дети"
    case careerAndMoney = "Карьера и деньги"
    case entertainmentAndRecreation = "Развлечения и отдых"
    case scienceAndResearch = "Наука и исследования"
    case improvingWorld = "Совершенствование мира"
    case selfDevelopment = "Саморазвитие"
    case beautyAndArt = "Красота и искусство"
    case fameAndInfluence = "Слава и влияние"
    case none
    
    static func get(by number: Int?) -> Self {
        if number == 1 {
            return .familyAndChildren
        } else if number == 2 {
            return .careerAndMoney
        } else if number == 3 {
            return .entertainmentAndRecreation
        } else if number == 4 {
            return .scienceAndResearch
        } else if number == 5 {
            return .improvingWorld
        } else if number == 6 {
            return .selfDevelopment
        } else if number == 7 {
            return .beautyAndArt
        } else if number == 8 {
            return .fameAndInfluence
        } else {
            return .none
        }
    }
}

enum PersonalPeopleMainType: String {
    case intelligenceAndCreativity = "Ум и креативность"
    case kindnessAndHonesty = "Доброта и честность"
    case healthAndBeauty = "Красота и здоровье"
    case powerAndWealth = "Власть и богатство"
    case courageAndPerseverance = "Смелость и упорство"
    case humorAndLoveOfLife = "Юмор и жизнелюбие"
    case none
    
    static func get(by number: Int?) -> Self {
        if number == 1 {
            return .intelligenceAndCreativity
        } else if number == 2 {
            return .kindnessAndHonesty
        } else if number == 3 {
            return .healthAndBeauty
        } else if number == 4 {
            return .powerAndWealth
        } else if number == 5 {
            return .courageAndPerseverance
        } else if number == 6 {
            return .humorAndLoveOfLife
        } else {
            return .none
        }
    }
}

struct ProfileResponse: Decodable {
    let id: Int?
    let firstName, lastName: String?
    let isClosed, canAccessClosed: Bool?
    let sex: Int?
    let screenName: String?
    let bdate: String?
    let nickname, domain: String?
    let country: Country?
    let city: City?
    let counters: Counters?
    let timezone: Int?
    let instagram: String?
    let photo100: String?
    let photo50, photo200, photo200Orig: String?
    let photoMax, photo400Orig, photoMaxOrig: String?
    let photoId: String?
    let hasPhoto, hasMobile, isFriend, friendStatus: Int?
    let canPost, canSeeAllPosts, canSeeAudio: Int?
    let canWritePrivateMessage, canSendFriendRequest: Int?
    let mobilePhone, homePhone, site, status: String?
    let lastSeen: LastSeen?
    let onlineInfo: OnlineInfo?
    let cropPhoto: CropPhoto?
    let verified: Int?
    let canBeInvitedGroup: Bool?
    let followersCount: Int?
    let blacklisted, blacklistedByMe, isFavorite: Int?
    let isHiddenFromFeed, commonCount: Int?
    let deactivated: String?
    let occupation: Occupation?
    let career: [Career]?
    let military: [Military]?
    let university: Int?
    let universityName: String?
    let faculty: Int?
    let facultyName: String?
    let graduation: Int?
    let homeTown: String?
    let relation: Int?
    let relationPartner: RelationPartner?
    let personal: Personal?
    let interests, music, activities, movies: String?
    let tv, books, games: String?
    let universities: [Universities]?
    let schools: [Schools]?
    let about: String?
    let relatives: [Relatives]?
    let quotes: String?
    let contacts: Contacts?
    let connections: Connections?
}

// MARK: - Response
struct SharedFriendResponse: Decodable {
    let response: [ResponseElement]
}

enum ResponseElement: Decodable {
    case integerArray([Int])
    case responseClass(ResponseClass)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode([Int].self) {
            self = .integerArray(x)
            return
        }
        if let x = try? container.decode(ResponseClass.self) {
            self = .responseClass(x)
            return
        }
        throw DecodingError.typeMismatch(ResponseElement.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for ResponseElement"))
    }
}

// MARK: - ResponseClass
struct ResponseClass: Decodable {
    let count: Int?
    let items: [Item]?
    let online, onlineMobile: [Int]?
}

// MARK: - Response
struct OnlineFriendResponse: Decodable {
    var online: [Int]
    var onlineMobile: [Int]
}

// MARK: - Response
struct FriendResponse: Decodable {
    var count: Int?
    var items: [FriendItem]?
}

// MARK: - Item
struct FriendItem: Decodable {
    let id: Int?
    let userId: Int?
    let firstName, lastName: String?
    let isClosed, canAccessClosed: Bool?
    let photo100: String?
    let onlineInfo: OnlineInfo?
    let online: Int?
    let trackCode, homeTown: String?
    let schools: [Schools]?
    let mutual: Mutual?
}

struct Mutual: Decodable {
    let count: Int?
}

// MARK: - Country
struct Country: Decodable {
    let id: Int?
    let title: String?
}

// MARK: - City
struct City: Decodable {
    let id: Int?
    let title: String?
}

// MARK: - Counters
struct Counters: Decodable {
    let photos: Int?
    let onlineFriends: Int?
    let subscriptions: Int?
    let albums: Int?
    let groups: Int?
    let clipsFollowers: Int?
    let mutualFriends: Int?
    let followers: Int?
    let pages: Int?
    let friends: Int?
    let gifts: Int?
    let audios: Int?
    let videos: Int?
}

// MARK: - Occupation
struct Occupation: Decodable {
    let type: String?
    let id: Int?
    let name: String?
}

// MARK: - OnlineInfo
struct OnlineInfo: Decodable {
    let visible: Bool?
    let lastSeen: Int?
    let isOnline: Bool?
    let appId: Int?
    let isMobile: Bool?
}

// MARK: - CropPhoto
struct CropPhoto: Decodable {
    let photo: ProfilePhoto?
    let crop, rect: Crop?
}

// MARK: - Crop
struct Crop: Decodable {
    let x: Double?
    let y: Double?
    let x2: Double?
    let y2: Double?
}

// MARK: - Photo
struct ProfilePhoto: Decodable {
    let albumId, date, id, ownerId: Int?
    let hasTags: Bool?
    let postId: Int?
    let sizes: [Size]?
    let text: String?
}

// MARK: - Size
struct Size: Decodable {
    let height: Int?
    let url: String?
    let type: String?
    let width: Int?
}

// MARK: - LastSeen
struct LastSeen: Decodable {
    let time, platform: Int?
}

// MARK: - Personal
struct Personal: Decodable {
    let peopleMain, lifeMain, smoking, alcohol: Int?
    let religion: String?
}

struct Career: Decodable {
    let groupId: Int?
    let company: String?
    let countryId: Int?
    let cityId: Int?
    let cityName: String?
    let from: Int?
    let until: Int?
    let position: String?
}

struct Military: Decodable {
    let unit: String?
    let unitId: Int?
    let countryId: Int?
    let from: Int?
    let until: Int?
}

struct Connections: Decodable {
    let skype: String?
    let facebook: String?
    let twitter: String?
    let livejournal: String?
    let instagram: String?
}

struct Contacts: Decodable {
    let mobilePhone: String?
    let homePhone: String?
}

struct Universities: Decodable {
    let id: Int?
    let country: Int?
    let city: Int?
    let name: String?
    let faculty: Int?
    let facultyName: String?
    let chair: Int?
    let chairName: String?
    let graduation: Int?
    let educationForm: String?
    let educationStatus: String?
}

struct Schools: Decodable {
    let id: Int?
    let country: Int?
    let city: Int?
    let name: String?
    let yearFrom: Int?
    let yearTo: Int?
    let yearGraduated: Int?
    let `class`: String?
    let speciality: String?
    let type: Int?
    let typeStr: String?
}

struct Relatives: Decodable {
    let id: Int?
    let name: String?
    let type: String?
}

struct RelationPartner: Decodable {
    let id: Int?
    let name: String?
}

struct GiftsResponse: Decodable {
    let count: Int
    let items: [GiftItem]
}
 
struct GiftItem: Decodable {
    let id: Int
    let fromId: Int
    let message: String
    let date: Int
    let gift: Gift
    let privacy: Int?
    let giftHash: String
}

struct Gift: Decodable {
    let id: Int
    let thumb256: String
    let thumb96: String
    let thumb48: String
    let stickersProductId: Int?
}
