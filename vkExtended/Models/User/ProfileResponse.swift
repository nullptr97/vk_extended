//
//  ProfileResponse.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 26.10.2020.
//

import Foundation
import SwiftyJSON

enum NameCase {
    case nom
    case gen
    case dat
    case acc
    case ins
    case abl
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

struct ProfileResponse {
    let id: Int
    let imageStatus: ImageStatus?
    let firstNameNom, lastNameNom: String
    let firstNameGen, lastNameGen: String
    let firstNameDat, lastNameDat: String
    let firstNameAcc, lastNameAcc: String
    let firstNameIns, lastNameIns: String
    let firstNameAbl, lastNameAbl: String
    let isClosed, canAccessClosed: Bool
    let sex: Int
    let screenName: String?
    let bdate: String?
    let nickname, domain: String?
    let country: Country?
    let city: City?
    let counters: Counters?
    let timezone: Int?
    let photo100: String
    let photo50, photo200, photo200Orig: String?
    let photoMax, photo400Orig, photoMaxOrig: String
    let photoId: String?
    let hasPhoto, isFriend, friendStatus: Int?
    let canPost, canSeeAllPosts, canSeeAudio: Int?
    let canWritePrivateMessage, canSendFriendRequest: Int?
    let site, status: String?
    let onlineInfo: OnlineInfo
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
    
    init(from profile: JSON) {
        self.firstNameNom = profile["first_name_nom"].stringValue
        self.lastNameNom = profile["last_name_nom"].stringValue
        self.firstNameGen = profile["first_name_gen"].stringValue
        self.lastNameGen = profile["last_name_gen"].stringValue
        self.firstNameDat = profile["first_name_dat"].stringValue
        self.lastNameDat = profile["last_name_dat"].stringValue
        self.firstNameAcc = profile["first_name_acc"].stringValue
        self.lastNameAcc = profile["last_name_acc"].stringValue
        self.firstNameIns = profile["first_name_ins"].stringValue
        self.lastNameIns = profile["last_name_ins"].stringValue
        self.firstNameAbl = profile["first_name_abl"].stringValue
        self.lastNameAbl = profile["last_name_abl"].stringValue
        
        self.imageStatus = ImageStatus(imageStatus: profile["image_status"])
        
        self.id = profile["id"].intValue
        self.canAccessClosed = profile["can_access_closed"].boolValue
        self.isClosed = profile["is_closed"].boolValue
        self.sex = profile["sex"].intValue
        self.screenName = profile["screen_name"].stringValue
        self.photo50 = profile["photo_50"].stringValue
        self.photo100 = profile["photo_100"].stringValue
        self.onlineInfo = OnlineInfo(onlineInfo: profile["online_info"])
        self.verified = profile["verified"].intValue
        self.friendStatus = profile["friend_status"].intValue
        self.nickname = profile["nickname"].stringValue
        self.domain = profile["domain"].stringValue
        self.bdate = profile["bdate"].stringValue
        self.country = Country(country: profile["country"])
        self.city = City(city: profile["city"])
        self.counters = Counters(counters: profile["counters"])
        self.timezone = profile["timezone"].intValue
        self.photo200 = profile["photo_200"].stringValue
        self.photoMax = profile["photo_max"].stringValue
        self.photo200Orig = profile["photo_200_orig"].stringValue
        self.photo400Orig = profile["photo_400_orig"].stringValue
        self.photoMaxOrig = profile["photo_max_orig"].stringValue
        self.photoId = profile["photo_id"].stringValue
        self.hasPhoto = profile["has_photo"].intValue
        self.isFriend = profile["is_friend"].intValue
        self.canPost = profile["can_post"].intValue
        self.canSeeAllPosts = profile["can_see_all_posts"].intValue
        self.canSeeAudio = profile["can_see_audio"].intValue
        self.interests = profile["interests"].stringValue
        self.books = profile["books"].stringValue
        self.tv = profile["tv"].stringValue
        self.quotes = profile["quotes"].stringValue
        self.about = profile["about"].stringValue
        self.games = profile["games"].stringValue
        self.movies = profile["movies"].stringValue
        self.activities = profile["activities"].stringValue
        self.music = profile["music"].stringValue
        self.canWritePrivateMessage = profile["can_write_private_message"].intValue
        self.canSendFriendRequest = profile["can_send_friend_request"].intValue
        self.canBeInvitedGroup = profile["can_be_invited_group"].boolValue
        self.site = profile["site"].stringValue
        self.status = profile["status"].stringValue
        self.cropPhoto = CropPhoto(cropPhoto: profile["crop_photo"])
        self.followersCount = profile["followers_count"].intValue
        self.blacklisted = profile["blacklisted"].intValue
        self.blacklistedByMe = profile["blacklisted_by_me"].intValue
        self.isFavorite = profile["is_favorite"].intValue
        self.isHiddenFromFeed = profile["is_hidden_from_feed"].intValue
        self.deactivated = profile["deactivated"].string
        self.commonCount = profile["common_count"].intValue
        self.occupation = Occupation(occupation: profile["occupation"])
        self.career = profile["career"].array?.compactMap { Career(career: $0) }
        self.military = profile["military"].array?.compactMap { Military(military: $0) }
        self.university = profile["university"].int
        self.universityName = profile[""].stringValue
        self.faculty = profile["faculty"].int
        self.facultyName = profile["faculty_name"].stringValue
        self.graduation = profile["graduation"].int
        self.homeTown = profile["home_town"].stringValue
        self.relation = profile["relation"].intValue
        self.relationPartner = RelationPartner(relationPartner: profile["relation_partner"])
        self.personal = Personal(personal: profile["personal"])
        self.universities = profile["universities"].array?.compactMap { Universities(universities: $0) }
        self.schools = profile["schools"].array?.compactMap { Schools(schools: $0) }
        self.relatives = profile["relatives"].array?.compactMap { Relatives(relatives: $0) }
        self.contacts = Contacts(contacts: profile["contacts"])
        self.connections = Connections(connections: profile["connections"])
    }
}

struct ImageStatus {
    let name: String
    let images: [StatusImageData]
    let id: Int
    
    init(imageStatus: JSON) {
        self.name = imageStatus["name"].stringValue
        self.images = imageStatus["images"].arrayValue.compactMap { StatusImageData(statusImageData: $0) }
        self.id = imageStatus["id"].intValue
    }
}

struct StatusImageData {
    let height: CGFloat
    let width: CGFloat
    let url: String
    
    init(statusImageData: JSON) {
        self.height = statusImageData["height"].intValue.cgFloat
        self.width = statusImageData["width"].intValue.cgFloat
        self.url = statusImageData["url"].stringValue
    }
}

struct Country {
    let id: Int?
    let title: String?
    
    init(country: JSON) {
        self.id = country["id"].int
        self.title = country["title"].string
    }
}

// MARK: - City
struct City {
    let id: Int?
    let title: String?
    
    init(city: JSON) {
        self.id = city["id"].int
        self.title = city["title"].string
    }
}

// MARK: - Counters
struct Counters {
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
    
    init(counters: JSON) {
        self.photos = counters["photos"].int
        self.onlineFriends = counters["online_friends"].int
        self.subscriptions = counters["subscriptions"].int
        self.albums = counters["albums"].int
        self.groups = counters["groups"].int
        self.clipsFollowers = counters["clips_followers"].int
        self.mutualFriends = counters["mutual_friends"].int
        self.followers = counters["followers"].int
        self.pages = counters["pages"].int
        self.friends = counters["friends"].int
        self.gifts = counters["gifts"].int
        self.audios = counters["audios"].int
        self.videos = counters["videos"].int
    }
}

// MARK: - Occupation
struct Occupation {
    let type: String?
    let id: Int?
    let name: String?
    
    init(occupation: JSON) {
        self.type = occupation["type"].string
        self.id = occupation["id"].int
        self.name = occupation["name"].string
    }
}

// MARK: - OnlineInfo
struct OnlineInfo: Decodable {
    var visible: Bool?
    var lastSeen: Int?
    var isOnline: Bool?
    var appId: Int?
    var isMobile: Bool?
    
    init(onlineInfo: JSON) {
        self.visible = onlineInfo["visible"].bool
        self.lastSeen = onlineInfo["last_seen"].int
        self.isOnline = onlineInfo["is_online"].bool
        self.appId = onlineInfo["app_id"].int
        self.isMobile = onlineInfo["is_mobile"].bool
    }
}

// MARK: - CropPhoto
struct CropPhoto {
    let photo: ProfilePhoto?
    let crop, rect: Crop?
    
    init(cropPhoto: JSON) {
        self.photo = ProfilePhoto(profilePhoto: cropPhoto["profile_photo"])
        self.crop = Crop(crop: cropPhoto["crop"])
        self.rect = Crop(crop: cropPhoto["rect"])
    }
}

// MARK: - Crop
struct Crop {
    let x: Double?
    let y: Double?
    let x2: Double?
    let y2: Double?
    
    init(crop: JSON) {
        self.x = crop["x"].double
        self.y = crop["y"].double
        self.x2 = crop["x2"].double
        self.y2 = crop["y2"].double
    }
}

// MARK: - Photo
struct ProfilePhoto {
    let albumId, date, id, ownerId: Int?
    let hasTags: Bool?
    let postId: Int?
    let sizes: [Size]?
    let text: String?
    
    init(profilePhoto: JSON) {
        self.albumId = profilePhoto["album_id"].int
        self.date = profilePhoto["date"].int
        self.ownerId = profilePhoto["owner_id"].int
        self.id = profilePhoto["id"].int
        self.sizes = profilePhoto["sizes"].arrayValue.compactMap { Size(size: $0) }
        self.hasTags = profilePhoto["has_tags"].bool
        self.postId = profilePhoto["post_id"].int
        self.text = profilePhoto["text"].string
    }
}

// MARK: - Size
struct Size: Decodable {
    let height: Int?
    let url: String?
    let type: String?
    let width: Int?
    
    init(size: JSON) {
        self.height = size["height"].int
        self.url = size["url"].string
        self.type = size["type"].string
        self.width = size["width"].int
    }
}

// MARK: - LastSeen
struct LastSeen {
    let time, platform: Int?
    
    init(lastSeen: JSON) {
        self.time = lastSeen["time"].int
        self.platform = lastSeen["platform"].int
    }
}

// MARK: - Personal
struct Personal {
    let peopleMain, lifeMain, smoking, alcohol: Int?
    let religion: String?
    
    init(personal: JSON) {
        self.peopleMain = personal["people_main"].int
        self.lifeMain = personal["life_main"].int
        self.smoking = personal["smoking"].int
        self.alcohol = personal["alcohol"].int
        self.religion = personal["religion"].string
    }
}

struct Career {
    let groupId: Int?
    let company: String?
    let countryId: Int?
    let cityId: Int?
    let cityName: String?
    let from: Int?
    let until: Int?
    let position: String?
    
    init(career: JSON) {
        self.groupId = career["group_id"].int
        self.company = career["company"].string
        self.countryId = career["country_id"].int
        self.cityId = career["city_id"].int
        self.cityName = career["city_name"].string
        self.from = career["from"].int
        self.until = career["until"].int
        self.position = career["position"].string
    }
}

struct Military {
    let unit: String?
    let unitId: Int?
    let countryId: Int?
    let from: Int?
    let until: Int?
    
    init(military: JSON) {
        self.unit = military["unit"].string
        self.unitId = military["unit_id"].int
        self.countryId = military["country_id"].int
        self.from = military["from"].int
        self.until = military["until"].int
    }
}

struct Connections {
    let skype: String?
    let facebook: String?
    let twitter: String?
    let livejournal: String?
    let instagram: String?
    
    init(connections: JSON) {
        self.skype = connections["skype"].string
        self.facebook = connections["facebook"].string
        self.twitter = connections["twitter"].string
        self.livejournal = connections["livejournal"].string
        self.instagram = connections["instagram"].string
    }
}

struct Contacts {
    let mobilePhone: String?
    let homePhone: String?
    
    init(contacts: JSON) {
        self.mobilePhone = contacts["mobile_phone"].string
        self.homePhone = contacts["home_phone"].string
    }
}

struct Universities {
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
    
    init(universities: JSON) {
        self.id = universities["id"].int
        self.country = universities["country"].int
        self.city = universities["city"].int
        self.name = universities["name"].string
        self.faculty = universities["faculty"].int
        self.facultyName = universities["faculty_name"].string
        self.chair = universities["chair"].int
        self.chairName = universities["chair_name"].string
        self.graduation = universities["graduation"].int
        self.educationForm = universities["education_form"].string
        self.educationStatus = universities["education_status"].string
    }
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
    
    init(schools: JSON) {
        self.id = schools["id"].int
        self.country = schools["country"].int
        self.city = schools["city"].int
        self.name = schools["name"].string
        self.yearFrom = schools["year_from"].int
        self.yearTo = schools["year_to"].int
        self.yearGraduated = schools["year_graduated"].int
        self.`class` = schools["class"].string
        self.speciality = schools["speciality"].string
        self.type = schools["type"].int
        self.typeStr = schools["type_str"].string
    }
}

struct Relatives {
    let id: Int?
    let name: String?
    let type: String?
    
    init(relatives: JSON) {
        self.type = relatives["type"].string
        self.id = relatives["id"].int
        self.name = relatives["name"].string
    }
}

struct RelationPartner {
    let id: Int?
    let name: String?
    
    init(relationPartner: JSON) {
        self.id = relationPartner["id"].int
        self.name = relationPartner["name"].string
    }
}
