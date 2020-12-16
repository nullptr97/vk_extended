//
//  ConversationsRouter.swift
//  vkExtended
//
//  Created Ярослав Стрельников on 20.10.2020.
//  Copyright © 2020 ExtendedTeam. All rights reserved.
//
import UIKit
import MaterialComponents

class ConversationsRouter: ConversationsWireframeProtocol {
    
    weak var viewController: UIViewController?
    weak var baseViewController: UIViewController?
    var transitioningDelegate = MDCBottomSheetTransitionController()
    
    // Инициализация VIPER модуля
    static func initModule(_ viewController: ConversationsViewController) {
        // Change to get view from storyboard if not using progammatic UI
        let interactor = ConversationsInteractor()
        let router = ConversationsRouter()
        let presenter = ConversationsPresenter(interface: viewController, interactor: interactor, router: router)
        
        viewController.presenter = presenter
        interactor.presenter = presenter
        router.viewController = viewController
        presenter.interactor = interactor
        router.baseViewController = viewController
    }
    
//    // Открыть чат
//    func openConversation(from conversation: Conversation) {
//        let chatViewController = ChatNewViewController(conversation: conversation)
//        chatViewController.hidesBottomBarWhenPushed = true
//        self.baseViewController?.navigationController?.pushViewController(chatViewController, animated: true)
//    }
    
    // Открыть профиль чата
    func openProfile(userId: Int) {
        self.baseViewController?.pushProfile(userId: userId)
    }
    
    // Открыть приватные переписки
    func openPrivateConversations() {
        let contentViewController = PrivateConversationsViewController()
//        contentViewController.transitioningDelegate = transitioningDelegate
        contentViewController.modalPresentationStyle = .fullScreen
        contentViewController.modalTransitionStyle = .crossDissolve
        baseViewController?.navigationController?.present(contentViewController, animated: true, completion: nil)
    }
}
