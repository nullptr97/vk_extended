//
//  VKGeneralDelegate.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 09.11.2020.
//

import Foundation
import SwiftyJSON

class VKGeneralDelegate: NSObject {
    static let instance: VKGeneralDelegate = VKGeneralDelegate()
    private let center = NotificationCenter.default
    private let conversationServiceInstance = ConversationService.instance

    override init() {
        super.init()
        VK.setUp(appId: Constants.appId, delegate: self)
        guard VK.sessions.default.state == .authorized else { return }
        conversationServiceInstance.startObserving()
        startLongPoll()
    }
    
    func startLongPoll() {
        VK.sessions.default.longPoll.start(version: LongPollVersion.third, onReceiveEvents: { [weak self] events in
            guard let self = self else { return }
            _ = events.map { event in
                switch event {
                case .forcedStop:
                    print("LongPoll forced stop")
                case .historyMayBeLost:
                    print("historyMayBeLost")
                case .type1(data: let data):
                    print("Event 1", data)
                case .type2(data: let data):
                    let userInfo: [AnyHashable: JSON] = ["set_flags": data]
                    self.center.post(name: .onSetMessageFlags, object: nil, userInfo: userInfo)
                    print("Event 2", data)
                case .type3(data: let data):
                    let userInfo: [AnyHashable: JSON] = ["reset_flags": data]
                    self.center.post(name: .onResetMessageFlags, object: nil, userInfo: userInfo)
                    print("Event 3", data)
                case .type4(data: let data):
                    let userInfo: [AnyHashable: JSON] = ["updates": data]
                    self.center.post(name: .onMessagesReceived, object: nil, userInfo: userInfo)
                    print("Event 4", data)
                case .type5(data: let data):
                    let userInfo: [AnyHashable: JSON] = ["updates": data]
                    self.center.post(name: .onMessagesEdited, object: nil, userInfo: userInfo)
                    print("Event 5", data)
                case .type6(data: let data):
                    let userInfo: [AnyHashable: JSON] = ["in_message": data]
                    self.center.post(name: .onInMessagesRead, object: nil, userInfo: userInfo)
                    print("Event 6", data)
                case .type7(data: let data):
                    let userInfo: [AnyHashable: JSON] = ["out_message": data]
                    self.center.post(name: .onOutMessagesRead, object: nil, userInfo: userInfo)
                    print("Event 7", data)
                case .type8(data: let data):
                    let userInfo: [AnyHashable: JSON] = ["updates": data]
                    self.center.post(name: .onFriendOnline, object: nil, userInfo: userInfo)
                    print("Event 8", data)
                case .type9(data: let data):
                    let userInfo: [AnyHashable: JSON] = ["updates": data]
                    self.center.post(name: .onFriendOffline, object: nil, userInfo: userInfo)
                    print("Event 9", data)
                case .type10(data: let data):
                    print("Event 10", data)
                case .type11(data: let data):
                    print("Event 11", data)
                case .type12(data: let data):
                    print("Event 12", data)
                case .type13(data: let data):
                    let userInfo: [AnyHashable: JSON] = ["remove_conversation": data]
                    self.center.post(name: .onRemoveConversation, object: nil, userInfo: userInfo)
                    print("Event 13", data)
                case .type14(data: let data):
                    print("Event 14", data)
                case .type51(data: let data):
                    print("Event 51", data)
                case .type52(data: let data):
                    print("Event 52", data)
                case .type61(data: let data):
                    let userInfo: [AnyHashable: JSON] = ["updates": data]
                    self.center.post(name: .onTyping, object: nil, userInfo: userInfo)
                    print("Event 61", data)
                case .type62(data: let data):
                    print("Event 62", data)
                case .type70(data: let data):
                    print("Event 70", data)
                case .type80(data: let data):
                    print("Event 80", data)
                case .type114(data: let data):
                    print("Event 114", data)
                }
            }
        })
    }
}
extension VKGeneralDelegate: ExtendedVKDelegate {
    func vkNeedsScopes(for sessionId: String) -> String {
        return "notify,friends,photos,audio,video,docs,status,notes,pages,wall,groups,messages,offline,notifications"
    }
    
    public func vkTokenCreated(for sessionId: String, info: [String: String]) {
        
    }
    
    public func vkTokenUpdated(for sessionId: String, info: [String: String]) {
        
    }
    
    public func vkTokenRemoved(for sessionId: String) {
        print("Session with id \(sessionId) destroyed")
        self.center.post(name: .onLogout, object: nil)
    }
}
