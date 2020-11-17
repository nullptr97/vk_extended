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
    
    func startObserving() {
        NotificationCenter.default.addObserver(self, selector: #selector(receiveMessages(_:)), name: .onMessagesReceived, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(editMessages(_:)), name: .onMessagesEdited, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userTyping(_:)), name: .onTyping, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setRead(_:)), name: .onOutMessagesRead, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setRead(_:)), name: .onInMessagesRead, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deleteMessage(_:)), name: .onSetMessageFlags, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(restoreMessage(_:)), name: .onResetMessageFlags, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeConversation(_:)), name: .onRemoveConversation, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(friendOnline(_:)), name: .onFriendOnline, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(friendOffline(_:)), name: .onFriendOffline, object: nil)
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
                let ids = items.map { item in
                    item["conversation"]["peer"]["id"].intValue
                }
                let missingConversations = realm.objects(Conversation.self).filter("NOT peerId IN %@", ids)
                try! realm.write {
                    realm.delete(missingConversations)
                }
            }
        }
    }
    
    func removeFakeSendingConversations() {
        serviceQueue.async {
            autoreleasepool {
                let realm = try! Realm()
                let missingConversations = realm.objects(Conversation.self).filter("isSending == %@", true)
                try! realm.write {
                    realm.delete(missingConversations)
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
    
    private func profile(for sourseId: Int, profiles: [JSON], groups: [JSON]) -> JSON {
        let profilesOrGroups: [JSON] = sourseId >= 0 ? profiles : groups
        let normalSourseId = sourseId >= 0 ? sourseId : -sourseId
        let profileRepresenatable = profilesOrGroups.first { (myProfileRepresenatable) -> Bool in
            myProfileRepresenatable["id"].intValue == normalSourseId
        }
        return profileRepresenatable!
    }
    
    @objc func receiveMessages(_ notification: Notification) {
        guard let longPollUpdates = notification.userInfo?["updates"] as? JSON else { return }
        let parameters: Alamofire.Parameters = [Parameter.messageIds.rawValue: longPollUpdates[1].intValue, Parameter.extended.rawValue: 1]
        Request.jsonRequest(method: ApiMethod.method(from: .messages, with: ApiMethod.Messages.getById), postFields: parameters).done { (response) in
            guard let response = response as? JSON, let item = response["items"].arrayValue.first else { return }
            self.serviceQueue.async {
                autoreleasepool {
                    let realm = try! Realm()
                    realm.beginWrite()
                    guard let conversation = realm.object(ofType: Conversation.self, forPrimaryKey: self.userServiceInstance.getNewPeerId(by: item["peer_id"].intValue)) else {
                        self.getNewConversation(by: self.userServiceInstance.getNewPeerId(by: item["peer_id"].intValue))
                        return
                    }
                    conversation.isTyping = false
                    conversation.lastMessageId = longPollUpdates[1].intValue
                    if longPollUpdates[3].intValue != self.userServiceInstance.getNewPeerId(by: item["from_id"].intValue) {
                        conversation.unreadCount = 0
                        conversation.inRead = longPollUpdates[1].intValue
                    } else {
                        conversation.unreadCount += 1
                        conversation.outRead = longPollUpdates[1].intValue
                    }
                    conversation.lastMessage = LastMessage(lastMessage: item)
                    print(conversation.lastMessageId, conversation.inRead, conversation.outRead ,conversation.unreadStatus)
                    
                    try! realm.commitWrite()
                }
            }
        }.catch { (error) in
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
    
    @objc func editMessages(_ notification: Notification) {
        serviceQueue.async {
            autoreleasepool {
                let realm = try! Realm()
                guard let longPollUpdates = notification.userInfo?["updates"] as? JSON else { return }
                guard let conversation = realm.object(ofType: Conversation.self, forPrimaryKey: self.userServiceInstance.getNewPeerId(by: longPollUpdates[2].intValue)) else { return }
                // guard let message = realm.objects(Message.self).filter("id == %@", longPollUpdates[0].intValue).first else { return }
                try! realm.safeWrite {
                    conversation.lastMessage?.text = longPollUpdates[5].stringValue
                    // message.text = longPollUpdates[5].stringValue
                }
            }
        }
    }
    
    @objc func setRead(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            serviceQueue.async {
                autoreleasepool {
                    if let updates = userInfo["in_message"] as? JSON {
                        self.setReadStatus(userId: updates[1].intValue, messageId: updates[2].intValue)
                    } else if let updates = userInfo["out_message"] as? JSON {
                        self.setReadStatus(userId: updates[1].intValue, messageId: updates[2].intValue)
                    }
                }
            }
        }
    }
    
    @objc func userTyping(_ notification: Notification) {
        guard let longPollUpdates = notification.userInfo?["updates"] as? JSON else { return }
        serviceQueue.async {
            autoreleasepool {
                let realm = try! Realm()
                realm.beginWrite()
                guard let conversationObject = realm.object(ofType: Conversation.self, forPrimaryKey: longPollUpdates[1].intValue) else { return }
                conversationObject.isTyping = true
                try! realm.commitWrite()
            }
        }
        serviceQueue.asyncAfter(deadline: .now() + 5, execute: {
            autoreleasepool {
                let realm = try! Realm()
                realm.beginWrite()
                guard let conversationObject = realm.object(ofType: Conversation.self, forPrimaryKey: longPollUpdates[1].intValue) else { return }
                conversationObject.isTyping = false
                try! realm.commitWrite()
            }
        })
    }
    
     @objc func deleteMessage(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let updates = userInfo["set_flags"] as? JSON {
                serviceQueue.async {
                    autoreleasepool {
                        for flag in Constants.removeMessageFlags {
                            if flag == updates[2].intValue {
                                let realm = try! Realm()
                                guard let conversationObject = realm.objects(Conversation.self).filter( { $0.peerId == updates[3].intValue }).first else { return }
                                //guard let messageObject = realm.objects(Message.self).filter("id == %@", updates[0].intValue).first else { return }
                                
                                try! realm.write {
                                    conversationObject.isRemoved = true
                                    conversationObject.removingFlag = updates[2].intValue
                                    //guard !messageObject.isInvalidated else { return }
                                    //messageObject.isRemoved = true
                                    //messageObject.removingFlag = updates[1].intValue
                                }
                                realm.refresh()
                            }
                        }
                    }
                }
            }
        }
     }
    
    @objc func restoreMessage(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let updates = userInfo["reset_flags"] as? JSON {
                serviceQueue.async {
                    autoreleasepool {
                        let realm = try! Realm()
                        guard let conversationObject = realm.objects(Conversation.self).filter( { $0.peerId == updates[3].intValue }).first else { return }
                        //guard let messageObject = realm.objects(Message.self).filter("id == %@", updates[0].intValue).first else { return }
                        
                        try! realm.write {
                            conversationObject.isRemoved = false
                            conversationObject.removingFlag = 0
                            //guard !messageObject.isInvalidated else { return }
                            //messageObject.isRemoved = true
                            //messageObject.removingFlag = updates[1].intValue
                        }
                        realm.refresh()
                    }
                }
            }
        }
    }
    
    @objc func removeConversation(_ notification: Notification) {
        serviceQueue.async {
            autoreleasepool {
                let realm = try! Realm()
                guard let removeJSON = notification.userInfo?["remove_conversation"] as? JSON else { return }
                guard let conversationObject = realm.object(ofType: Conversation.self, forPrimaryKey: removeJSON[1].intValue) else { return }
                try! realm.write {
                    realm.delete(conversationObject)
                }
                realm.refresh()
            }
        }
    }
    
    
    @objc func friendOnline(_ notification: Notification) {
        guard let peerId = (notification.userInfo?["updates"] as? JSON)?[1].intValue else { return }
        guard let isMobile = (notification.userInfo?["updates"] as? JSON)?[2].intValue == 7 ? false : true else { return }
        serviceQueue.asyncAfter(deadline: .now() + 1, execute: {
            autoreleasepool {
                let realm = try! Realm()
                guard let conversation = realm.object(ofType: Conversation.self, forPrimaryKey: self.userServiceInstance.getNewPeerId(by: peerId * -1)) else { return }
                try! realm.safeWrite {
                    conversation.interlocutor?.isOnline = true
                    conversation.interlocutor?.isMobile = isMobile
                }
            }
        })
    }
    
    @objc func friendOffline(_ notification: Notification) {
        guard let peerId = (notification.userInfo?["updates"] as? JSON)?[1].intValue else { return }
        serviceQueue.asyncAfter(deadline: .now() + 1, execute: { [self] in
            autoreleasepool {
                let realm = try! Realm()
                guard let conversation = realm.object(ofType: Conversation.self, forPrimaryKey: self.userServiceInstance.getNewPeerId(by: peerId * -1)) else { return }
                try! realm.safeWrite {
                    conversation.interlocutor?.isOnline = false
                    conversation.interlocutor?.isMobile = false
                }
            }
        })
    }
}
