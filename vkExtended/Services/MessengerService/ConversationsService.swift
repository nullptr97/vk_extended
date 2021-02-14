//
//  ConversationsService.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 01.11.2020.
//

import Foundation
import RealmSwift
import SwiftyJSON
import Alamofire

class ConversationService: NSObject {
    static let instance: ConversationService = ConversationService()
    let userServiceInstance = UserService.instance
    let serviceQueue = DispatchQueue(label: "messageServiceQueue", qos: .default, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
    private var pool = Notice.ObserverPool()

    func startObserving() {
        Notice.Center.default.observe(name: .messagesReceived) { [weak self] receivedMessage in
            guard let self = self else { return }
            self.receiveMessages(from: receivedMessage.updateEventJSON["updates"])
        }.invalidated(by: pool)
        
        Notice.Center.default.observe(name: .editMessage) { [weak self] receivedMessage in
            guard let self = self else { return }
            self.editMessages(from: receivedMessage.updateEventJSON["updates"])
        }.invalidated(by: pool)

        Notice.Center.default.observe(name: .typing) { [weak self] receivedMessage in
            guard let self = self else { return }
            self.userTyping(from: receivedMessage.updateEventJSON["updates"])
        }.invalidated(by: pool)
        
        Notice.Center.default.observe(name: .readMessage) { [weak self] receivedMessage in
            guard let self = self else { return }
            self.readMessage(from: receivedMessage.updateEventJSON["updates"])
        }.invalidated(by: pool)
        
        Notice.Center.default.observe(name: .removeMessage) { [weak self] receivedMessage in
            guard let self = self else { return }
            self.removeMessage(from: receivedMessage.updateEventJSON["updates"])
        }.invalidated(by: pool)
        
        Notice.Center.default.observe(name: .restoreMessage) { [weak self] receivedMessage in
            guard let self = self else { return }
            self.restoreMessage(from: receivedMessage.updateEventJSON["updates"])
        }.invalidated(by: pool)
        
        Notice.Center.default.observe(name: .removeConversation) { [weak self] receivedMessage in
            guard let self = self else { return }
            self.removeConversation(from: receivedMessage.updateEventJSON["updates"])
        }.invalidated(by: pool)
        
        Notice.Center.default.observe(name: .friendOnline) { [weak self] receivedMessage in
            guard let self = self else { return }
            self.friendOnline(from: receivedMessage.updateEventJSON["updates"])
        }.invalidated(by: pool)
        
        Notice.Center.default.observe(name: .friendOffline) { [weak self] receivedMessage in
            guard let self = self else { return }
            self.friendOffline(from: receivedMessage.updateEventJSON["updates"])
        }.invalidated(by: pool)
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
    
    static func messageTime(date: Date) -> String {
        let timestamp: NSNumber = NSNumber(value: date.timeIntervalSince1970)
        let seconds = timestamp.doubleValue
        let timestampDate = Date(timeIntervalSince1970: seconds)
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        
        dateFormatter.dateFormat = "H:mm"
        let formatDate = dateFormatter.string(from: timestampDate)
        return formatDate
    }
    
    func setReadStatus(userId: Int, messageId: Int) {
        let realm = try! Realm()
        guard let conversationObject = realm.objects(Conversation.self).filter({ $0.peerId == userId }).first else { return }
        try! realm.write {
            conversationObject.inRead = messageId
            conversationObject.outRead = messageId
            conversationObject.lastMessageId = messageId
            conversationObject.unreadCount = 0
        }
        realm.refresh()
    }
    
    func removeMissingConversations(by items: [JSON]) {
        serviceQueue.async {
            autoreleasepool {
                let realm = try! Realm()
                var ids: [Int] = items.map { $0["conversation"]["peer"]["id"].intValue }
                let conversationsPeerIds: [Int] = realm.objects(Conversation.self).map { $0.peerId }
                ids.append(contentsOf: conversationsPeerIds)
                let mPeerIds = ids.withoutDuplicates()
                 
                let missingConversations = realm.objects(Conversation.self).filter("NOT peerId IN %@", mPeerIds)
                try! realm.write {
                    realm.delete(missingConversations)
                    print("missed conversation from peedId \(missingConversations.map { $0.peerId }) removed")
                }
            }
        }
    }
    
    func updateDb(by response: JSON) {
        serviceQueue.async {
            autoreleasepool {
                let realm = try! Realm()
                let items = response["items"].arrayValue
                
                try! realm.write {
                    for item in items {
                        let id = item["conversation"]["peer"]["id"].intValue
                        let fromId = item["last_message"]["from_id"].intValue

                        let profiles = response["profiles"].arrayValue
                        let groups = response["groups"].arrayValue
                        
                        if id > 2000000000 {
                            let senderType = self.profile(for: fromId, profiles: profiles, groups: groups)
                            let conversation: Conversation = Conversation(conversation: item["conversation"], lastMessage: item["last_message"], representable: senderType)
                            realm.add(conversation, update: .modified)
                        } else {
                            let senderType = self.profile(for: id, profiles: profiles, groups: groups)
                            let conversation: Conversation = Conversation(conversation: item["conversation"], lastMessage: item["last_message"], representable: senderType)
                            realm.add(conversation, update: .modified)
                        }
                    }
                }
            }
        }
    }
    
    func updateDb(by conversations: [Conversation]) {
        serviceQueue.async {
            let realm = try! Realm()

            try! realm.write {
                conversations.compactMap { realm.add($0, update: .modified) }
            }
        }
    }
    
    func conversations(from item: JSON, with profiles: [JSON] = [], with groups: [JSON] = []) -> Conversation {
        let id = item["conversation"]["peer"]["id"].intValue
        let fromId = item["last_message"]["from_id"].intValue
        
        let senderType =
            ConversationService.instance.profile(for: id > 2000000000 ? fromId : id, profiles: profiles, groups: groups)
        let conversation: Conversation = Conversation(conversation: item["conversation"], lastMessage: item["last_message"], representable: senderType)
        return conversation
    }
    
    func profile(for sourseId: Int, profiles: [JSON], groups: [JSON]) -> JSON {
        let profilesOrGroups: [JSON] = sourseId >= 0 ? profiles : groups
        let normalSourseId = sourseId >= 0 ? sourseId : -sourseId
        let profileRepresenatable = profilesOrGroups.first { (myProfileRepresenatable) -> Bool in
            myProfileRepresenatable["id"].intValue == normalSourseId
        }
        return profileRepresenatable!
    }
    
    func receiveMessages(from longPollUpdates: JSON) {
        try! Api.Messages.getMessageById(messageIds: longPollUpdates[1].intValue.string).done() { [weak self] item in
            guard let self = self else { return }
            self.serviceQueue.async {
                autoreleasepool {
                    let realm = try! Realm()
                    guard let conversation = realm.objects(Conversation.self).filter({ $0.peerId == self.userServiceInstance.getNewPeerId(by: item["peer_id"].intValue) }).first else {
                        self.getNewConversation(by: self.userServiceInstance.getNewPeerId(by: item["peer_id"].intValue))
                        return
                    }
                    try! realm.safeWrite {
                        conversation.isTyping = false
                        conversation.lastMessageId = longPollUpdates[1].intValue
                        if longPollUpdates[3].intValue != self.userServiceInstance.getNewPeerId(by: item["from_id"].intValue) && item["out"].intValue == 1 {
                            conversation.nullableCounter()
                            conversation.inRead = longPollUpdates[1].intValue
                        } else if longPollUpdates[3].intValue != self.userServiceInstance.getNewPeerId(by: item["from_id"].intValue) && item["out"].intValue == 0 {
                            conversation.increaseCounter()
                            conversation.outRead = longPollUpdates[1].intValue
                        } else if longPollUpdates[3].intValue == self.userServiceInstance.getNewPeerId(by: item["from_id"].intValue) {
                            conversation.nullableCounter()
                            conversation.inRead = longPollUpdates[1].intValue
                            conversation.outRead = longPollUpdates[1].intValue
                        }
                        conversation.lastMessage = LastMessage(lastMessage: item)
                    }
                }
            }
        }.catch { error in
            print(error.localizedDescription)
        }
    }
    
    func getNewConversation(by peerId: Int) {
        let parameters: Alamofire.Parameters = [Parameter.count.rawValue: 200, Parameter.extended.rawValue: 1]
        Request.jsonRequest(method: ApiMethod.method(from: .messages, with: ApiMethod.Messages.getConversations), postFields: parameters).done { [weak self] data in
            guard let self = self else { return }
            self.updateDb(by: JSON(data))
        }.catch { error in
            print(error.localizedDescription)
        }
    }
    
    func editMessages(from longPollUpdates: JSON) {
        serviceQueue.async {
            autoreleasepool {
                let realm = try! Realm()
                guard let conversation = realm.objects(Conversation.self).filter({ $0.peerId == self.userServiceInstance.getNewPeerId(by: longPollUpdates[3].intValue) }).first else { return }
                try! realm.safeWrite {
                    conversation.lastMessage?.text = longPollUpdates[6].stringValue
                }
            }
        }
    }
    
    func readMessage(from longPollUpdates: JSON) {
        serviceQueue.async {
            autoreleasepool {
                self.setReadStatus(userId: longPollUpdates[1].intValue, messageId: longPollUpdates[2].intValue)
            }
        }
    }
    
    func userTyping(from longPollUpdates: JSON) {
        serviceQueue.async {
            autoreleasepool {
                let realm = try! Realm()
                realm.beginWrite()
                guard let conversation = realm.objects(Conversation.self).filter({ $0.peerId == self.userServiceInstance.getNewPeerId(by: longPollUpdates[1].intValue) }).first else { return }
                conversation.isTyping = true
                try! realm.commitWrite()
            }
        }
        serviceQueue.asyncAfter(deadline: .now() + 5, execute: {
            autoreleasepool {
                let realm = try! Realm()
                realm.beginWrite()
                guard let conversation = realm.objects(Conversation.self).filter({ $0.peerId == self.userServiceInstance.getNewPeerId(by: longPollUpdates[1].intValue) }).first else { return }
                conversation.isTyping = false
                try! realm.commitWrite()
            }
        })
    }
    
     func removeMessage(from longPollUpdates: JSON) {
        serviceQueue.async {
            autoreleasepool {
                for flag in Constants.removeMessageFlags {
                    if flag == longPollUpdates[2].intValue {
                        let realm = try! Realm()
                        guard let conversation = realm.objects(Conversation.self).filter({ $0.peerId == self.userServiceInstance.getNewPeerId(by: longPollUpdates[3].intValue) }).first else { return }
                        
                        try! realm.write {
                            conversation.isRemoved = true
                            conversation.removingFlag = longPollUpdates[2].intValue
                        }
                        realm.refresh()
                    }
                }
            }
        }
     }
    
    func restoreMessage(from longPollUpdates: JSON) {
        serviceQueue.async {
            autoreleasepool {
                let realm = try! Realm()
                guard let conversation = realm.objects(Conversation.self).filter({ $0.peerId == self.userServiceInstance.getNewPeerId(by: longPollUpdates[3].intValue) }).first else { return }
                
                try! realm.write {
                    conversation.isRemoved = false
                    conversation.removingFlag = 0
                }
                realm.refresh()
            }
        }
    }
    
    func removeConversation(from longPollUpdates: JSON) {
        serviceQueue.async {
            autoreleasepool {
                let realm = try! Realm()
                guard let conversation = realm.objects(Conversation.self).filter({ $0.peerId == self.userServiceInstance.getNewPeerId(by: longPollUpdates[1].intValue) }).first else { return }
                try! realm.safeWrite {
                    realm.delete(conversation)
                }
                realm.refresh()
            }
        }
    }
    
    
    func friendOnline(from longPollUpdates: JSON) {
        let peerId = longPollUpdates[1].intValue
        guard let isMobile = longPollUpdates[2].intValue == 7 ? false : true else { return }
        serviceQueue.asyncAfter(deadline: .now() + 1, execute: {
            autoreleasepool {
                let realm = try! Realm()
                guard let conversation = realm.objects(Conversation.self).filter({ $0.peerId == self.userServiceInstance.getNewPeerId(by: peerId * -1) }).first else { return }
                try! realm.safeWrite {
                    conversation.interlocutor?.isOnline = true
                    conversation.interlocutor?.isMobile = isMobile
                }
            }
        })
    }
    
    func friendOffline(from longPollUpdates: JSON) {
        let peerId = longPollUpdates[1].intValue
        serviceQueue.asyncAfter(deadline: .now() + 1, execute: { [self] in
            autoreleasepool {
                let realm = try! Realm()
                guard let conversation = realm.objects(Conversation.self).filter({ $0.peerId == self.userServiceInstance.getNewPeerId(by: peerId * -1) }).first else { return }
                try! realm.safeWrite {
                    conversation.interlocutor?.isOnline = false
                    conversation.interlocutor?.isMobile = false
                }
            }
        })
    }
}
