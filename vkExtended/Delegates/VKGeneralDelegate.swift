//
//  VKGeneralDelegate.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 09.11.2020.
//

import Foundation
import SwiftyJSON
import Alamofire

class VKGeneralDelegate: NSObject {
    private let center = NotificationCenter.default
    private let conversationServiceInstance = ConversationService.instance

    override init() {
        super.init()
        VK.setUp(appId: Constants.appId, delegate: self)
        guard VK.sessions.default.state == .authorized else { return }
        startLongPoll()
        conversationServiceInstance.startObserving()
    }
    
    func startLongPoll() {
        VK.sessions.default.longPoll.start(version: LongPollVersion.third, onReceiveEvents: { events in
            _ = events.map { event in
                switch event {
                case .forcedStop:
                    print("LongPoll forced stop")
                case .historyMayBeLost:
                    print("historyMayBeLost")
                case .type1(data: let data):
                    print("Event 1", data)
                case .type2(data: let data):
                    let event = NoticeLongPollEvent(updateEventJSON: ["updates": data])
                    Notice.Center.default.post(name: .removeMessage, with: event)
                    print("Event 2", data)
                case .type3(data: let data):
                    let event = NoticeLongPollEvent(updateEventJSON: ["updates": data])
                    Notice.Center.default.post(name: .restoreMessage, with: event)
                    print("Event 3", data)
                case .type4(data: let data):
                    let event = NoticeLongPollEvent(updateEventJSON: ["updates": data])
                    Notice.Center.default.post(name: .messagesReceived, with: event)
                    print("Event 4", data)
                case .type5(data: let data):
                    let event = NoticeLongPollEvent(updateEventJSON: ["updates": data])
                    Notice.Center.default.post(name: .editMessage, with: event)
                    print("Event 5", data)
                case .type6(data: let data), .type7(data: let data):
                    let event = NoticeLongPollEvent(updateEventJSON: ["updates": data])
                    Notice.Center.default.post(name: .readMessage, with: event)
                    print("Event 6/7", data)
                case .type8(data: let data):
                    let event = NoticeLongPollEvent(updateEventJSON: ["updates": data])
                    Notice.Center.default.post(name: .friendOnline, with: event)
                    print("Event 8", data)
                case .type9(data: let data):
                    let event = NoticeLongPollEvent(updateEventJSON: ["updates": data])
                    Notice.Center.default.post(name: .friendOffline, with: event)
                    print("Event 9", data)
                case .type10(data: let data):
                    print("Event 10", data)
                case .type11(data: let data):
                    print("Event 11", data)
                case .type12(data: let data):
                    print("Event 12", data)
                case .type13(data: let data):
                    let event = NoticeLongPollEvent(updateEventJSON: ["updates": data])
                    Notice.Center.default.post(name: .removeConversation, with: event)
                    print("Event 13", data)
                case .type14(data: let data):
                    print("Event 14", data)
                case .type51(data: let data):
                    print("Event 51", data)
                case .type52(data: let data):
                    print("Event 52", data)
                case .type61(data: let data):
                    let event = NoticeLongPollEvent(updateEventJSON: ["updates": data])
                    Notice.Center.default.post(name: .typing, with: event)
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
    
    func registerDevice(token: String) {
        let parameters: Alamofire.Parameters = [
            Parameter.token.rawValue: token,
            Parameter.deviceModel.rawValue: UIDevice.current.model,
            Parameter.deviceId.rawValue: UIDevice.current.identifierForVendor?.uuidString ?? .random(20),
            Parameter.systemVersion.rawValue: UIDevice.current.systemVersion,
            Parameter.settings.rawValue: Constants.pushSettings
        ]
        
        Request.jsonRequest(method: ApiMethod.method(from: .account, with: ApiMethod.Account.registerDevice), postFields: parameters).done { response in
            print(JSON(response))
        }.catch { error in
            print(error.localizedDescription)
        }
    }
}
extension VKGeneralDelegate: ExtendedVKDelegate {
    func vkNeedsScopes(for sessionId: String) -> String {
        return "notify,friends,photos,audio,video,docs,status,notes,pages,wall,groups,messages,offline,notifications"
    }
    
    public func vkTokenCreated(for sessionId: String, info: [String: String]) {
        print(sessionId, info)
    }
    
    public func vkTokenUpdated(for sessionId: String, info: [String: String]) {
        print(sessionId, info)
    }
    
    public func vkTokenRemoved(for sessionId: String) {
        print("Session with id \(sessionId) destroyed")
        self.center.post(name: .onLogout, object: nil)
    }
}
