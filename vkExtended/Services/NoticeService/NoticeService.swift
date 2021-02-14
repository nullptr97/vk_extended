//
//  NoticeService.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 11.01.2021.
//

import Foundation
import UIKit
import SwiftyJSON

extension Notice.Names {
    static let removeConversation = Notice.Name<NoticeLongPollEvent>(.onRemoveConversation)
    
    static let messagesReceived = Notice.Name<NoticeLongPollEvent>(.onMessagesReceived)
    
    static let restoreMessage = Notice.Name<NoticeLongPollEvent>(.onResetMessageFlags)
    static let removeMessage = Notice.Name<NoticeLongPollEvent>(.onSetMessageFlags)
    static let editMessage = Notice.Name<NoticeLongPollEvent>(.onMessagesEdited)
    static let readMessage = Notice.Name<NoticeLongPollEvent>(.onMessagesRead)
    
    static let typing = Notice.Name<NoticeLongPollEvent>(.onTyping)
    
    static let friendOnline = Notice.Name<NoticeLongPollEvent>(.onFriendOnline)
    static let friendOffline = Notice.Name<NoticeLongPollEvent>(.onFriendOffline)
}

struct NoticeLongPollEvent {
    let updateEventJSON: JSON
}
