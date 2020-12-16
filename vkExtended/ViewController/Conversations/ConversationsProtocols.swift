//
//  ConversationsProtocols.swift
//  vkExtended
//
//  Created Ярослав Стрельников on 20.10.2020.
//  Copyright © 2020 ExtendedTeam. All rights reserved.
//
import Foundation
import Alamofire

//MARK: Wireframe -
protocol ConversationsWireframeProtocol: class {
    func openProfile(userId: Int)
    func openPrivateConversations()
}
//MARK: Presenter -
protocol ConversationsPresenterProtocol: class {
    func getConversations(offset: Int)
    func onEvent(message: String, isError: Bool)
    func onFinishRequest()
    func onTapPerformProfile(from peerId: Int)
    func onTapReadConversation(from peerId: Int)
    func onTapUnreadConversation(from peerId: Int)
    func onChangeSilenceMode(from peerId: Int, sound: Int)
    func onDeleteConversation(from peerId: Int)
    func onOpenPrivateConversations()
    func onRemoveMultipleConversations(by peerIds: [Int])
}

//MARK: Interactor -
protocol ConversationsInteractorProtocol: class {
    var presenter: ConversationsPresenterProtocol? { get set }
    func getConversations(offset: Int)
    func readMessage(peerId: Int)
    func markAsUnreadConversation(peerId: Int)
    func setSilenceMode(peerId: Int, sound: Int)
    func deleteConversation(peerId: Int)
    func removeMultipleConversations(by peerIds: [Int])
}

//MARK: View -
protocol ConversationsViewProtocol: class {
    var presenter: ConversationsPresenterProtocol? { get set }
    func stopRefreshControl()
    func event(message: String, isError: Bool)
}
