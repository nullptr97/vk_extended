//
//  ServicesMenuInteractor.swift
//  vkExtended
//
//  Created Ярослав Стрельников on 15.11.2020.
//  Copyright © 2020 ExtendedTeam. All rights reserved.
//
import UIKit
import Alamofire
import SwiftyJSON
import IGListKit
import AwesomeCache

class ServicesMenuInteractor: ServicesMenuInteractorProtocol {

    weak var presenter: ServicesMenuPresenterProtocol?
    private let cache = try! Cache<NSData>(name: "superAppCache")
    
    func getSuperApp(lat: Double?, lon: Double?) {
        
        if let superAppCache = cache["superApp"] as Data? {
            let response = SuperAppServices(from: superAppCache.json())
            presenter?.onPresent(response)
        }
        
        do {
            try Api.SuperApp.get(lat: lat, lon: lon).done { [weak self] superApp in
                guard let self = self else { return }
                self.presenter?.onPresent(superApp)
            }.catch { error in
                print(error)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

// MARK: - SuperApp
class SuperAppServices: ListDiffable {
    private var identifier: String = UUID().uuidString

    let miniApps: [MiniApp]
    let items: [SuperAppItem]
    let count: Int
    let updateOptions: UpdateOptions
    
    init(from superApp: JSON) {
        self.miniApps = superApp["mini_apps"].arrayValue.map { MiniApp(from: $0) }
        self.items = superApp["items"].arrayValue.compactMap { SuperAppItem(from: $0) }
        self.count = superApp["count"].intValue
        self.updateOptions = UpdateOptions(from: superApp["update_options"])
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? SuperAppServices else {
            return false
        }
        
        return self.identifier == object.identifier
    }
}

// MARK: - SuperAppItem
struct SuperAppItem {
    let size: String
    let object: SuperAppObject
    let type: String
    let updateOptions: UpdateOptions?
    
    init(from superAppItem: JSON) {
        self.size = superAppItem["size"].stringValue
        self.object = SuperAppObject(from: superAppItem["object"])
        self.type = superAppItem["type"].stringValue
        self.updateOptions = UpdateOptions(from: superAppItem["update_options"])
    }
}


// MARK: - Object
struct SuperAppObject {
    let count: Int?
    let items: [ObjectItem]?
    let button: Button?
    let webviewURL: String?
    let title, localIncreaseLabel: String?
    let appID, totalIncrease: Int?
    let timelineDynamic: [Double]?
    let totalIncreaseLabel: String?
    let localIncrease: Int?
    let images: [CoverPhotosURL]?
    let temperature, shortDescriptionAdditionalValue, shortDescription, mainDescription: String?
    let trackCode, additionalText, mainText: String?
    let link: String?
    let coverPhotosURL, headerIcon: [CoverPhotosURL]?
    let payload: Payload?
    let state, footerText: String?
    let buttonExtra: ButtonExtra?
    let matches: [Match]?
    let isLocal: Bool?
    
    init(from object: JSON) {
        self.count = object["count"].int
        self.items = object["items"].array?.compactMap { ObjectItem(from: $0) }
        self.button = Button(from: object["button"])
        self.webviewURL = object["webview_url"].stringValue
        self.title = object["title"].string
        self.localIncreaseLabel = object["local_increase_label"].string
        self.appID = object["app_id"].int
        self.totalIncrease = object["total_increase"].int
        self.timelineDynamic = object["timeline_dynamic"].array?.map { $0.doubleValue }
        self.totalIncreaseLabel = object["total_increase_label"].string
        self.localIncrease = object["local_increase"].int
        self.images = object["images"].array?.map { CoverPhotosURL(from: $0) }
        self.temperature = object["temperature"].string
        self.shortDescriptionAdditionalValue = object["short_description_additional_value"].string
        self.shortDescription = object["short_description"].string
        self.mainDescription = object["main_description"].string
        self.trackCode = object["track_code"].string
        self.additionalText = object["additional_text"].string
        self.mainText = object["main_text"].string
        self.link = object["link"].string
        self.coverPhotosURL = object["cover_photos_url"].array?.map { CoverPhotosURL(from: $0) }
        self.headerIcon = object["header_icon"].array?.map { CoverPhotosURL(from: $0) }
        self.payload = Payload(from: object["payload"])
        self.state = object["state"].string
        self.footerText = object["footer_text"].string
        self.buttonExtra = ButtonExtra(from: object["button_extra"])
        self.matches = object["matches"].array?.map { Match(from: $0) }
        self.isLocal = object["is_local"].bool
    }
}

// MARK: - Button
struct Button {
    let title: String
    let action: Action
    
    init(from button: JSON) {
        self.title = button["title"].stringValue
        self.action = Action(from: button)
    }
}

struct Action {
    let url: String
    let type, target: String
    
    init(from action: JSON) {
        self.url = action["url"].stringValue
        self.type = action["type"].stringValue
        self.target = action["target"].stringValue
    }
}

// MARK: - ButtonExtra
struct ButtonExtra {
    let title: String
    let webviewURL: String
    let appId: Int
    
    init(from buttonExtra: JSON) {
        self.title = buttonExtra["title"].stringValue
        self.webviewURL = buttonExtra["webview_url"].stringValue
        self.appId = buttonExtra["app_id"].intValue
    }
}

// MARK: - CoverPhotosURL
struct CoverPhotosURL: Codable {
    let height: Int
    let url: String
    let width: Int
    
    init(from coverPhotosURL: JSON) {
        self.height = coverPhotosURL["height"].intValue
        self.url = coverPhotosURL["url"].stringValue
        self.width = coverPhotosURL["width"].intValue
    }
}

// MARK: - ObjectItem
struct ObjectItem {
    let name, badgeText: String?
    let images: [CoverPhotosURL]?
    let title: String?
    let appId: Int?
    let type: String?
    let to, from: Int?
    let text: String?
    let deltaAbsolute: Double?
    let baseCurrency: String?
    let webviewURL: String?
    let currency, currencySymbol: String?
    let value: Double?
    let id: String?
    let deltaPercent: Double?
    
    init(from objectItem: JSON) {
        self.name = objectItem["name"].string
        self.badgeText = objectItem["badge_text"].string
        self.images = objectItem["images"].arrayValue.compactMap { CoverPhotosURL(from: $0) }
        self.title = objectItem["title"].string
        self.appId = objectItem["app_id"].int
        self.type = objectItem["type"].string
        self.to = objectItem["to"].int
        self.from = objectItem["from"].int
        self.text = objectItem["text"].string
        self.deltaAbsolute = objectItem["delta_absolute"].double
        self.baseCurrency = objectItem["base_currency"].string
        self.webviewURL = objectItem["webview_url"].string
        self.currency = objectItem["currency"].string
        self.currencySymbol = objectItem["currency_symbol"].string
        self.value = objectItem["value"].double
        self.id = objectItem["id"].string
        self.deltaPercent = objectItem["delta_percent"].double
    }
}

// MARK: - Match
struct Match {
    let score: Score
    let state: String
    let teamB, teamA: Team
    let webviewURL: String
    
    init(from match: JSON) {
        self.score = Score(from: match["score"])
        self.state = match["state"].stringValue
        self.teamB = Team(from: match["team_b"])
        self.teamA = Team(from: match["team_b"])
        self.webviewURL = match["webview_url"].stringValue
    }
}
// MARK: - Score
struct Score {
    let teamB, scorePostfix, scorePrefix, teamA: String

    init(from score: JSON) {
        self.teamB = score["team_b"].stringValue
        self.scorePostfix = score["postfix"].stringValue
        self.scorePrefix = score["prefix"].stringValue
        self.teamA = score["team_a"].stringValue
    }
}

// MARK: - Team
struct Team {
    let teamDescription, name: String
    let icons: [CoverPhotosURL]
    
    init(from team: JSON) {
        self.teamDescription = team["description"].stringValue
        self.name = team["name"].stringValue
        self.icons = team["icons"].arrayValue.compactMap { CoverPhotosURL(from: $0) }
    }
}

// MARK: - Payload
struct Payload: Codable {
    let label, buttonLabel: String

    enum CodingKeys: String, CodingKey {
        case label
        case buttonLabel = "button_label"
    }
    
    init(from payload: JSON) {
        self.label = payload["label"].stringValue
        self.buttonLabel = payload["button_label"].stringValue
    }
}

// MARK: - UpdateOptions
struct UpdateOptions {
    let ttl: Int
    let updateOnOpen, updateOnClose: Bool
    
    init(from updateOptions: JSON) {
        self.ttl = updateOptions["ttl"].intValue
        self.updateOnOpen = updateOptions["update_on_open"].boolValue
        self.updateOnClose = updateOptions["update_on_close"].boolValue
    }
}

struct MiniApp {
    let trackCode: String
    let icon576: String
    let openInExternalBrowser: Bool
    let icon139: String
    let isInstalled, isVkuiInternal, isFavorite: Bool
    let backgroundLoaderColor: String?
    let webviewURL: String
    let title: String
    let areNotificationsEnabled: Bool
    let type: MiniAppType
    let icon75: String
    let loaderIcon: String?
    let icon278: String
    let authorOwnerID: Int
    let icon150: String
    let id: Int

    init(from miniApp: JSON) {
        self.trackCode = miniApp["track_code"].stringValue
        self.icon576 = miniApp["icon_576"].stringValue
        self.openInExternalBrowser = miniApp["open_in_external_browser"].boolValue
        self.icon139 = miniApp["icon_139"].stringValue
        self.isInstalled = miniApp["is_installed"].boolValue
        self.isVkuiInternal = miniApp["is_vkui_internal"].boolValue
        self.isFavorite = miniApp["is_favorite"].boolValue
        self.backgroundLoaderColor = miniApp["background_loader_color"].stringValue
        self.webviewURL = miniApp["webview_url"].stringValue
        self.title = miniApp["title"].stringValue
        self.areNotificationsEnabled = miniApp["are_notifications_enabled"].boolValue
        self.type = MiniAppType.miniApp
        self.icon75 = miniApp["icon_75"].stringValue
        self.loaderIcon = miniApp["loader_icon"].stringValue
        self.icon278 = miniApp["icon_278"].stringValue
        self.authorOwnerID = miniApp["author_owner_id"].intValue
        self.icon150 = miniApp["icon_150"].stringValue
        self.id = miniApp["id"].intValue
    }
}

enum MiniAppType: String, Codable {
    case miniApp = "mini_app"
}
