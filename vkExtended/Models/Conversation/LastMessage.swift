//
//  LastMessage.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 01.11.2020.
//

import Foundation
import RealmSwift
import SwiftyJSON
 
class LastMessage: Object {
    @objc dynamic var peerId: Int = 0
    @objc dynamic var date: String = "0"
    @objc dynamic var dateInteger: Int = 0
    @objc dynamic var fromId: Int = 0
    @objc dynamic var messageId: Int = 0
    @objc dynamic var out: Int = 0
    @objc dynamic var text: String = "0"
    @objc dynamic var conversationMessageId: Int = 0
    @objc dynamic var isImportantMessage: Bool = false
    @objc dynamic var randomId: Int = 0
    @objc dynamic var actionType: MessageAction.RawValue = ""
    
    @objc dynamic var attachmentType: MessageAttachmentType.RawValue = MessageAttachmentType.none.rawValue

    @objc dynamic var forwardMessagesCount: Int = 0
    @objc dynamic var hasReplyMessage: Bool = false
    @objc dynamic var hasAttachments: Bool = false
    @objc dynamic var hasForwardedMessages: Bool = false
    
    @objc dynamic var isRemoved: Bool = false
    @objc dynamic var removingFlag: Int = 0
    
    convenience init(lastMessage: JSON) {
        self.init()
        self.date = Conversation.messageTime(time: lastMessage["date"].intValue)
        self.dateInteger = lastMessage["date"].intValue
        self.fromId = lastMessage["from_id"].intValue
        self.out = lastMessage["out"].intValue
        self.peerId = lastMessage["peer_id"].intValue
        self.text = lastMessage["text"].stringValue
        self.conversationMessageId = lastMessage["conversation_message_id"].intValue
        self.isImportantMessage = lastMessage["important"].boolValue
        self.randomId = lastMessage["random_id"].intValue
        self.isRemoved = false
        self.removingFlag = 0
        self.actionType = MessageAction.action(by: lastMessage["action"]["type"].stringValue).rawValue
        
        if lastMessage["attachments"].array?.count ?? 0 == 1 {
            self.attachmentType = Conversation.typeAttachment(string: lastMessage["attachments"].array?.first?["type"].stringValue).rawValue
        } else {
            self.attachmentType = "\(lastMessage["attachments"].array?.count ?? 0) \(getStringByDeclension(number: lastMessage["attachments"].array?.count ?? 0, arrayWords: Localization.attachmentsString))"
        }
        self.hasAttachments = lastMessage["attachments"].array?.first?["type"].stringValue != nil
        self.forwardMessagesCount = lastMessage["fwd_messages"].arrayValue.count
        self.hasForwardedMessages = lastMessage["fwd_messages"].arrayValue.count > 0
        self.hasReplyMessage = !(lastMessage["reply_message"] == JSON.null)
    }
}
