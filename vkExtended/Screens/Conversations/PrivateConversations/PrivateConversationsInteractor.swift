//
//  PrivateConversationsInteractor.swift
//  vkExtended
//
//  Created Ярослав Стрельников on 14.11.2020.
//  Copyright © 2020 ExtendedTeam. All rights reserved.
//
import UIKit
import Alamofire
import RealmSwift

class PrivateConversationsInteractor: PrivateConversationsInteractorProtocol {

    weak var presenter: PrivateConversationsPresenterProtocol?
    
    // Прочитать сообщение
    func readMessage(peerId: Int) {
        let parameters: Alamofire.Parameters = [Parameter.peerId.rawValue: peerId]
        Request.dataRequest(method: ApiMethod.method(from: .messages, with: ApiMethod.Messages.markAsRead), parameters: parameters, hasEventMethod: true).done { [weak self] response in
            guard let self = self else { return }
            switch response {
            case .success:
                DispatchQueue.global(qos: .background).async {
                    autoreleasepool {
                        let realm = try! Realm()
                        guard let conversation = realm.objects(Conversation.self).filter("peerId == %@", peerId).first else { return }
                        try! realm.write {
                            conversation.unreadCount = 0
                            conversation.isMarkedUnread = false
                        }
                    }
                }
                self.presenter?.onEvent(message: "Сообщение прочитано", isError: false)
            case .error(let error):
                self.presenter?.onEvent(message: error.toApi()?.message ?? "", isError: true)
            }
        }.catch { error in
            self.presenter?.onEvent(message: error.toVK().localizedDescription, isError: true)
        }
    }
    
    // Пометить непрочитанным
    func markAsUnreadConversation(peerId: Int) {
        let parameters: Alamofire.Parameters = [Parameter.peerId.rawValue: peerId]
        Request.dataRequest(method: ApiMethod.method(from: .messages, with: ApiMethod.Messages.markAsUnread), parameters: parameters, hasEventMethod: true).done { [weak self] response in
            guard let self = self else { return }
            switch response {
            case .success:
                DispatchQueue.global(qos: .background).async {
                    autoreleasepool {
                        let realm = try! Realm()
                        guard let conversation = realm.objects(Conversation.self).filter("peerId == %@", peerId).first else { return }
                        try! realm.write {
                            conversation.isMarkedUnread = true
                        }
                    }
                }
                self.presenter?.onEvent(message: "Сообщение непрочитано", isError: false)
            case .error(let error):
                self.presenter?.onEvent(message: error.toApi()?.message ?? "", isError: true)
            }
        }.catch { error in
            self.presenter?.onEvent(message: error.toVK().localizedDescription, isError: true)
        }
    }
    
    // Установить режим уведомления для чата
    func setSilenceMode(peerId: Int, sound: Int) {
        let parameters: Alamofire.Parameters = [Parameter.peerId.rawValue: peerId, Parameter.sound.rawValue: sound, Parameter.time.rawValue: sound == 1 ? 0 : -1]
        Request.dataRequest(method: ApiMethod.method(from: .account, with: ApiMethod.Account.setSilenceMode), parameters: parameters, hasEventMethod: true).done { [weak self] response in
            guard let self = self else { return }
            switch response {
            case .success:
                DispatchQueue.global(qos: .background).async {
                    autoreleasepool {
                        let realm = try! Realm()
                        guard let conversation = realm.objects(Conversation.self).filter("peerId == %@", peerId).first else { return }
                        try! realm.write {
                            conversation.disabledForever = sound == 0
                            conversation.noSound = sound == 0
                        }
                    }
                }
                self.presenter?.onEvent(message: "Уведомления \(sound == 1 ? "включены" : "выключены")", isError: false)
            case .error(let error):
                self.presenter?.onEvent(message: error.toApi()?.message ?? "", isError: true)
            }
        }.catch { error in
            self.presenter?.onEvent(message: error.toVK().localizedDescription, isError: true)
        }
    }
    
    // Удаление переписки
    func deleteConversation(peerId: Int) {
        let parameters: Alamofire.Parameters = [Parameter.peerId.rawValue: peerId]
        Request.dataRequest(method: ApiMethod.method(from: .messages, with: ApiMethod.Messages.deleteConversation), parameters: parameters).done { [weak self] response in
            guard let self = self else { return }
            switch response {
            case .success:
                DispatchQueue.global(qos: .background).async {
                    autoreleasepool {
                        let realm = try! Realm()
                        guard let conversation = realm.objects(Conversation.self).filter("peerId == %@", peerId).first else { return }
                        try! realm.write {
                            realm.delete(conversation)
                        }
                    }
                }
                self.presenter?.onEvent(message: "Чат удалён", isError: false)
            case .error(let error):
                self.presenter?.onEvent(message: error.toApi()?.message ?? "", isError: true)
            }
        }.catch { error in
            self.presenter?.onEvent(message: error.toVK().localizedDescription, isError: true)
        }
    }
}
