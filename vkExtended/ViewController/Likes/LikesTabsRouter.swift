//
//  LikesTabsRouter.swift
//  vkExtended
//
//  Created Ярослав Стрельников on 26.10.2020.
//  Copyright © 2020 ExtendedTeam. All rights reserved.
//
import UIKit

class LikesTabsRouter: LikesTabsWireframeProtocol {
    
    weak var viewController: UIViewController?
    weak var baseViewController: UIViewController?
    
    static func initModule(_ viewController: LikesTabsViewController) {
        // Change to get view from storyboard if not using progammatic UI
        let interactor = LikesTabsInteractor()
        let router = LikesTabsRouter()
        let presenter = LikesTabsPresenter(interface: viewController, interactor: interactor, router: router)
        
        viewController.presenter = presenter
        interactor.presenter = presenter
        router.viewController = viewController
        presenter.interactor = interactor
        router.baseViewController = viewController
    }
    
    func openProfile(from userId: Int) {
        let profileViewController: UIViewController = ProfileViewController(userId: userId)
        baseViewController?.navigationController?.pushViewController(profileViewController, animated: true)
    }
}
