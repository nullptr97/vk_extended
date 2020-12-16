//
//  NewsfeedViewModels.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 23.11.2020.
//

import Foundation
import IGListKit

class NewsfeedHeaderViewModel: ListDiffable {
    private var identifier: String = UUID().uuidString

    var iconUrlString: String
    var name: String
    var date: String
    
    init(iconUrlString: String, name: String, date: String) {
        self.iconUrlString = iconUrlString
        self.name = name
        self.date = date
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? NewsfeedHeaderViewModel else {
            return false
        }
        
        return self.identifier == object.identifier
    }
}

class RepostHeaderViewModel: ListDiffable {
    private var identifier: String = UUID().uuidString

    var iconUrlString: String
    var name: String
    var date: String
    
    init(iconUrlString: String, name: String, date: String) {
        self.iconUrlString = iconUrlString
        self.name = name
        self.date = date
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? RepostHeaderViewModel else {
            return false
        }
        
        return self.identifier == object.identifier
    }
}

class NewsfeedTextViewModel: ListDiffable {
    private var identifier: String = UUID().uuidString

    var text: String?
    var isReveal: Bool
    
    init(text: String?, isReveal: Bool) {
        self.text = text
        self.isReveal = isReveal
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? NewsfeedTextViewModel else {
            return false
        }
        
        return self.identifier == object.identifier
    }
}

class RepostTextViewModel: ListDiffable {
    private var identifier: String = UUID().uuidString

    var text: String?
    
    init(text: String?) {
        self.text = text
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? RepostTextViewModel else {
            return false
        }
        
        return self.identifier == object.identifier
    }
}

class NewsfeedPhotoAttachmentsViewModel: ListDiffable {
    private var identifier: String = UUID().uuidString

    var photoAttachements: [AttachmentCellViewModel]
    
    init(photoAttachements: [AttachmentCellViewModel]) {
        self.photoAttachements = photoAttachements
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? NewsfeedPhotoAttachmentsViewModel else {
            return false
        }
        
        return self.identifier == object.identifier
    }
}

class NewsfeedAudioAttachmentsViewModel: ListDiffable {
    private var identifier: String = UUID().uuidString

    var audioAttachements: [AudioCellViewModel]
    
    init(audioAttachements: [AudioCellViewModel]) {
        self.audioAttachements = audioAttachements
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? NewsfeedAudioAttachmentsViewModel else {
            return false
        }
        
        return self.identifier == object.identifier
    }
}

class NewsfeedEventAttachmentsViewModel: ListDiffable {
    private var identifier: String = UUID().uuidString

    var eventAttachements: [EventCellViewModel]
    
    init(eventAttachements: [EventCellViewModel]) {
        self.eventAttachements = eventAttachements
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? NewsfeedEventAttachmentsViewModel else {
            return false
        }
        
        return self.identifier == object.identifier
    }
}

class NewsfeedFooterViewModel: ListDiffable {
    private var identifier: String = UUID().uuidString

    var likes: String?
    var userLikes: Int?
    var comments: String?
    var shares: String?
    var views: String?
    
    init(likes: String?, userLikes: Int?, comments: String?, shares: String?, views: String?) {
        self.likes = likes
        self.userLikes = userLikes
        self.comments = comments
        self.shares = shares
        self.views = views
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? NewsfeedFooterViewModel else {
            return false
        }
        
        return self.identifier == object.identifier
    }
}

class NewsfeedDividerViewModel: ListDiffable {
    private var identifier: String = UUID().uuidString
    
    func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? NewsfeedDividerViewModel else {
            return false
        }
        
        return self.identifier == object.identifier
    }
}

class SuperAppObjectViewModel: ListDiffable {
    private var identifier: String = UUID().uuidString
    let miniApp: MiniApp?
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
    
    init(miniApp: MiniApp?, count: Int?, items: [ObjectItem]?, button: Button?, webviewURL: String?, title: String?, localIncreaseLabel: String?, appID: Int?, totalIncrease: Int?, timelineDynamic: [Double]?, totalIncreaseLabel: String?, localIncrease: Int?, images: [CoverPhotosURL]?, temperature: String?, shortDescriptionAdditionalValue: String?, shortDescription: String?, mainDescription: String?, trackCode: String?, additionalText: String?, mainText: String?, link: String?, coverPhotosURL: [CoverPhotosURL]?, headerIcon: [CoverPhotosURL]?, payload: Payload?, state: String?, footerText: String?, buttonExtra: ButtonExtra?, matches: [Match]?, isLocal: Bool?) {
        self.miniApp = miniApp
        self.count = count
        self.items = items
        self.button = button
        self.webviewURL = webviewURL
        self.title = title
        self.localIncreaseLabel = localIncreaseLabel
        self.appID = appID
        self.totalIncrease = totalIncrease
        self.timelineDynamic = timelineDynamic
        self.totalIncreaseLabel = totalIncreaseLabel
        self.localIncrease = localIncrease
        self.images = images
        self.temperature = temperature
        self.shortDescriptionAdditionalValue = shortDescriptionAdditionalValue
        self.shortDescription = shortDescription
        self.mainDescription = mainDescription
        self.trackCode = trackCode
        self.additionalText = additionalText
        self.mainText = mainText
        self.link = link
        self.coverPhotosURL = coverPhotosURL
        self.headerIcon = headerIcon
        self.payload = payload
        self.state = state
        self.footerText = footerText
        self.buttonExtra = buttonExtra
        self.matches = matches
        self.isLocal = isLocal
    }
    
    var type: ServiceCellType {
        return ServiceCellType.getType(by: appID, from: title)
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? SuperAppObjectViewModel else {
            return false
        }
        
        return self.identifier == object.identifier
    }
}

enum ServiceItemType {
    case music
    case groups
    case videos
    case files
    case settings
    case debug
    case unknown
}

class ServiceItemViewModel: ListDiffable {
    private var identifier: String = UUID().uuidString
    let image: String
    let name: String
    let color: UIColor

    var type: ServiceItemType {
        switch name {
        case "Музыка":
            return .music
        case "Сообщества":
            return .groups
        case "Видео":
            return .videos
        case "Файлы":
            return .files
        case "Настройки":
            return .settings
        case "Debug":
            return .debug
        default:
            return .unknown
        }
    }
    
    init(image: String, name: String, color: UIColor) {
        self.image = image
        self.name = name
        self.color = color
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? ServiceItemViewModel else {
            return false
        }
        
        return self.identifier == object.identifier
    }
}
