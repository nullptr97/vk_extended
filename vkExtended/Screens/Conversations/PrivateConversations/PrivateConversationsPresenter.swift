//
//  PrivateConversationsPresenter.swift
//  vkExtended
//
//  Created Ярослав Стрельников on 14.11.2020.
//  Copyright © 2020 ExtendedTeam. All rights reserved.
//
import UIKit

class PrivateConversationsPresenter: PrivateConversationsPresenterProtocol {

    weak private var view: PrivateConversationsViewProtocol?
    var interactor: PrivateConversationsInteractorProtocol?
    private let router: PrivateConversationsWireframeProtocol

    init(interface: PrivateConversationsViewProtocol, interactor: PrivateConversationsInteractorProtocol?, router: PrivateConversationsWireframeProtocol) {
        self.view = interface
        self.interactor = interactor
        self.router = router
    }
    
    // Действие при событии
    func onEvent(message: String, isError: Bool = false) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.view?.event(message: message, isError: isError)
        })
    }

    // При переходе в профиль
    func onTapPerformProfile(from peerId: Int) {
        router.openProfile(userId: peerId)
    }
    
    // Обработка смены режима уведомлений
    func onChangeSilenceMode(from peerId: Int, sound: Int) {
        guard let interactor = interactor else { return }
        interactor.setSilenceMode(peerId: peerId, sound: sound)
    }
    
    // Oбработка удаления диалога
    func onDeleteConversation(from peerId: Int) {
        guard let interactor = interactor else { return }
        interactor.deleteConversation(peerId: peerId)
    }
    
    // Обработка действия "Прочитать сообщение"
    func onTapReadConversation(from peerId: Int) {
        guard let interactor = interactor else { return }
        interactor.readMessage(peerId: peerId)
    }
    
    // Обработка действия "Отметить сообщение непрочитанным"
    func onTapUnreadConversation(from peerId: Int) {
        guard let interactor = interactor else { return }
        interactor.markAsUnreadConversation(peerId: peerId)
    }
    
    // Обработка действия "Заркыть окно приватных чатов"
    func onClosePrivateConversations() {
        router.closePrivateConversations()
    }
}
