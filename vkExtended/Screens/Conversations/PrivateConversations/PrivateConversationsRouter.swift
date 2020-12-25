//
//  PrivateConversationsRouter.swift
//  vkExtended
//
//  Created Ярослав Стрельников on 14.11.2020.
//  Copyright © 2020 ExtendedTeam. All rights reserved.
//
import UIKit

class PrivateConversationsRouter: PrivateConversationsWireframeProtocol {
    
    weak var viewController: UIViewController?
    weak var baseViewController: UIViewController?
    
    static func initModule(_ viewController: PrivateConversationsViewController) {
        // Change to get view from storyboard if not using progammatic UI
        let interactor = PrivateConversationsInteractor()
        let router = PrivateConversationsRouter()
        let presenter = PrivateConversationsPresenter(interface: viewController, interactor: interactor, router: router)
        
        viewController.presenter = presenter
        interactor.presenter = presenter
        router.viewController = viewController
        presenter.interactor = interactor
        router.baseViewController = viewController
    }
    
    // Открыть профиль чата
    func openProfile(userId: Int) {
        self.baseViewController?.navigationController?.pushViewController(ProfileViewController(userId: userId), animated: true)
    }
    
    // Закрыть окно приватных переписок
    func closePrivateConversations() {
        self.baseViewController?.dismiss(animated: true, completion: nil)
    }
}
