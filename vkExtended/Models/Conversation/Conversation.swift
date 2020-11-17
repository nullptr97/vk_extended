//
//  Conversation.swift
//  VK Exteded
//
//  Created by programmist_np on 06.05.2020.
//  Copyright © 2020 programmist_np. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

enum ConversationPeerType: String {
    case user
    case group
    case chat
    
    static func get(by rawValue: String) -> Self {
        if rawValue == "user" {
            return .user
        } else if rawValue == "group" {
            return .group
        } else {
            return .chat
        }
    }
}

enum ReadStatus: String {
    case unreadIn
    case unreadOut
    case read
    case markedUnread
}

public enum MessageAction: String {
    case chatPhotoUpdate = "обновлена фотография беседы"
    case chatPhotoRemove = "удалена фотография беседы"
    case chatCreate = "создана беседа"
    case chatTitleUpdate = "обновлено название беседы"
    case chatInviteUser = "приглашен пользователь"
    case chatKickUser = "исключен пользователь"
    case chatKickUserWhereUserId = "вышел из беседы"
    case chatPinMessage = "закреплено сообщение"
    case chatUnpinMessage = "откреплено сообщение"
    case chatInviteUserByLink = "пользователь присоединился к беседе по ссылке"
    case unknown = ""
    
    static func action(by rawValue: String) -> Self {
        switch rawValue {
        case "chat_photo_update":
            return .chatPhotoUpdate
        case "chat_photo_remove":
            return .chatPhotoRemove
        case "chat_create":
            return .chatCreate
        case "chat_title_update":
            return .chatTitleUpdate
        case "chat_invite_user":
            return .chatInviteUser
        case "chat_kick_user":
            return .chatKickUser
        case "chat_pin_message":
            return .chatPinMessage
        case "chat_unpin_message":
            return .chatUnpinMessage
        case "chat_invite_user_by_link":
            return .chatInviteUserByLink
        default:
            return .unknown
        }
    }
}

class Conversation: Object {
    // MARK: Conversation
    @objc dynamic var peerId: Int = 0
    @objc dynamic var type: String = ""
    @objc dynamic var localId: Int = 0
    @objc dynamic var lastMessageId: Int = 0
    @objc dynamic var inRead: Int = 0
    @objc dynamic var outRead: Int = 0
    @objc dynamic var canWriteAllowed: Bool = false
    @objc dynamic var canWriteReason: Int = 0
    @objc dynamic var isImportantDialog: Bool = false
    @objc dynamic var isMarkedUnread: Bool = false
    // Chat Settings
    @objc dynamic var membersCount: Int = 0
    @objc dynamic var title: String?
    // var pinnedMessage: DBMessage?
    @objc dynamic var state: String?
    var activeIds: [Int] = []
    @objc var ownerId: Int = Constants.currentUserId
    @objc dynamic var isGroupChannel: Bool = false
    // Push Settings
    @objc dynamic var disabledUntil: Int = 0
    @objc dynamic var disabledForever: Bool = false
    @objc dynamic var noSound: Bool = false
    @objc dynamic var unreadCount: Int = 0
    @objc dynamic var isTyping: Bool = false
    // MARK: Last Message
    @objc dynamic var lastMessage: LastMessage?
    // MARK: Interlocutor
    @objc dynamic var interlocutor: ConversationInterlocutor?
    // MARK: NEW FEATURES
    // Stored removing messages
    @objc dynamic var isRemoved: Bool = false
    @objc dynamic var removingFlag: Int = 0
    // Aggressive Typing
    @objc dynamic var isAggressiveTypingActive: Bool = false
    @objc dynamic var aggressiveTypingType: String = "none"
    // Private conversation
    @objc dynamic var isPrivateConversation: Bool = false
    
    convenience init(conversation: JSON, lastMessage: JSON?, representable: JSON) {
        self.init()
        // MARK: Conversation
        self.peerId = conversation["peer"]["id"].intValue
        self.type = conversation["peer"]["type"].stringValue
        self.localId = conversation["peer"]["local_id"].intValue
        self.lastMessageId = conversation["last_message_id"].intValue
        self.inRead = conversation["in_read"].intValue
        self.outRead = conversation["out_read"].intValue
        self.canWriteAllowed = conversation["can_write"]["allowed"].boolValue
        self.canWriteReason = conversation["can_write"]["reason"].intValue
        self.isMarkedUnread = conversation["is_marked_unread"].boolValue
        self.isImportantDialog = UserDefaults.standard.bool(forKey: "importantStateFrom\(self.peerId)")
        self.isAggressiveTypingActive = UserDefaults.standard.bool(forKey: "permanent_typing_from\(self.peerId)")
        self.isPrivateConversation = UserDefaults.standard.bool(forKey: "privateConversationFrom\(self.peerId)")
        self.membersCount = conversation["chat_settings"]["members_count"].intValue
        self.title = conversation["chat_settings"]["title"].stringValue
        self.unreadCount = conversation["unread_count"].intValue
        self.state = conversation["chat_settings"]["state"].stringValue
        self.activeIds.append(contentsOf: conversation["chat_settings"]["active_ids"].arrayValue.map { $0.intValue })
        self.isGroupChannel = conversation["chat_settings"]["is_group_channel"].boolValue
        self.aggressiveTypingType = self.isAggressiveTypingActive ? UserDefaults.standard.string(forKey: "permanent_typing_type_from\(self.peerId)") ?? "none" : "none"
        self.disabledUntil = conversation["push_settings"].dictionary?["disabled_until"]?.intValue ?? 0
        self.disabledForever = conversation["push_settings"].dictionary?["disabled_forever"]?.boolValue ?? false
        self.noSound = conversation["push_settings"].dictionary?["no_sound"]?.boolValue ?? false
        // MARK: LastMessage
        self.isTyping = false
        if let lastMessage = lastMessage {
            self.lastMessage = LastMessage(lastMessage: lastMessage)
        }
        switch ConversationPeerType.get(by: conversation["peer"]["type"].stringValue) {
        case .user:
            self.interlocutor = ConversationInterlocutor(profileJSON: representable)
        case .group:
            self.interlocutor = ConversationInterlocutor(groupJSON: representable)
        case .chat:
            self.interlocutor = ConversationInterlocutor(conversation: conversation, chatJSON: representable)
        }
    }

    var isOutgoing: Bool {
        return lastMessage?.out == 1 ? true : false
    }
    
    open var isMuted: Bool {
        return disabledUntil > 0 || disabledForever
    }
    
    open var unreadStatus: ReadStatus {
        if inRead < lastMessageId || unreadCount > 0 {
            return .unreadIn
        } else if outRead < lastMessageId {
            return .unreadOut
        }else if (inRead == lastMessageId) && (outRead == lastMessageId) {
            return .read
        } else if isMarkedUnread {
            return .markedUnread
        } else {
            return .read
        }
    }
    
    class func getSenderShortName(from name: String) -> String {
        guard let first = name.byWords.first, var second = name.byWords.last else { return "" }
        while String(second).count > 1 {
            second.removeLast()
        }
        let finalName = first + " " + second
        return String(finalName)
    }

    class func getAvatarAcronymColor(at idIndex: Int, completion: @escaping(_ color: UIColor) -> Void) {
        for index in 0...idIndex {
            if index < 6 {
                completion(.systemBlue)
            } else {
                continue
            }
        }
    }
    
    class func typeAttachment(string: String?) -> MessageAttachmentType {
        switch string {
        case "photo":
            return .photo
        case "video":
            return .video
        case "audio":
            return .audio
        case "audio_message":
            return .audio_message
        case "doc":
            return .doc
        case "link":
            return .link
        case "market":
            return .market
        case "market_album":
            return .market_album
        case "wall":
            return .wall
        case "wall_reply":
            return .wall_reply
        case "sticker":
            return .sticker
        case "gift":
            return .gift
        case "graffiti":
            return .graffity
        case "call":
            return .call
        case "":
            return .none
        default:
            return .unknown
        }
    }
    
    func getCanWriteMessage(by reason: Int) -> String {
        switch reason {
        case 18: return "Пользователь заблокирован или удален"
        case 900: return "Пользователь в черном списке"
        case 901: return "Пользователь запретил сообщения от сообщества"
        case 902: return "Пользователь ограничил круг лиц, которые ему могут написать"
        case 915: return "В сообществе отключены сообщения"
        case 916: return "В сообществе заблокированы сообщения"
        case 917: return "Нет доступа к чату"
        case 918: return "Нет доступа к e-mail"
        case 925: return "Это канал сообщества"
        case 945: return "Беседа закрыта"
        case 203: return "Нет доступа к сообществу"
        default: return "Запрещено (неизвестный код)"
        }
    }
    
    static func messageTime(time: Int) -> String {
        let date = Date(timeIntervalSince1970: Double(time))
        let timestamp: NSNumber = NSNumber(value: date.timeIntervalSince1970)
        let seconds = timestamp.doubleValue
        let timestampDate = Date(timeIntervalSince1970: seconds)
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        
        dateFormatter.dateFormat = "H:mm"
        let formatDate = dateFormatter.string(from: timestampDate)
        return formatDate
    }
    
    override class func primaryKey() -> String? {
        return "peerId"
    }
}

@objc protocol ConversationSenderRepresenatable {
    var id: Int { get }
    var name: String { get }
    var photo: String { get }
    @objc optional var sex: Int { get }
    @objc optional var verified: Int { get }
    @objc optional var isOnline: Bool { get }
    @objc optional var isMobileOnline: Bool { get }
    @objc optional var onlinePlatform: Int { get }
    @objc optional var lastSeen: Int { get }
}

class ConversationInterlocutor: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var photo100: String = ""
    @objc dynamic var visible: Bool = false
    @objc dynamic var lastSeen: Int = 0
    @objc dynamic var isOnline: Bool = false
    @objc dynamic var appId: Int = 0
    @objc dynamic var isMobile: Bool = false
    @objc dynamic var sex: Int = 0
    @objc dynamic var verified: Int = 0
    @objc dynamic var name: String = ""
    
    dynamic var senderId: Int? = 0
    @objc dynamic var senderName: String? = ""
    @objc dynamic var senderPhoto100: String? = ""
    
    dynamic var type: ConversationPeerType = .user
    
    convenience init(profileJSON: JSON) {
        self.init()
        self.id = profileJSON["id"].intValue
        self.name = profileJSON["first_name"].stringValue + " " + profileJSON["last_name"].stringValue
        self.photo100 = profileJSON["photo_100"].stringValue
        self.visible = profileJSON["online_info"]["visible"].boolValue
        self.lastSeen = profileJSON["online_info"]["last_seen"].intValue
        self.isOnline = profileJSON["online_info"]["is_online"].boolValue
        self.appId = profileJSON["online_info"]["app_id"].intValue
        self.isMobile = profileJSON["online_info"]["is_mobile"].boolValue
        self.sex = profileJSON["sex"].intValue
        self.verified = profileJSON["verified"].intValue
        self.type = .user
    }
    
    convenience init(groupJSON: JSON) {
        self.init()
        self.id = groupJSON["id"].intValue
        self.name = groupJSON["name"].stringValue
        self.photo100 = groupJSON["photo_100"].stringValue
        self.verified = groupJSON["verified"].intValue
        self.type = .group
    }
    
    convenience init(conversation: JSON, chatJSON: JSON) {
        self.init()
        self.id = conversation["peer"]["id"].intValue
        self.name = conversation["chat_settings"]["title"].stringValue
        self.photo100 = conversation["chat_settings"]["photo"]["photo_100"].stringValue
        
        self.senderId = chatJSON["id"].intValue
        self.senderName = chatJSON["first_name"].stringValue + " " + chatJSON["last_name"].stringValue
        self.senderPhoto100 = chatJSON["photo_100"].stringValue
        self.verified = chatJSON["verified"].intValue
        self.sex = chatJSON["sex"].intValue
        self.type = .chat
    }
}
