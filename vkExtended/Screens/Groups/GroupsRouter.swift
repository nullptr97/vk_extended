//
//  GroupsRouter.swift
//  vkExtended
//
//  Created Ярослав Стрельников on 26.10.2020.
//  Copyright © 2020 ___ORGANIZATIONNAME___. All rights reserved.
//
import UIKit

class GroupsRouter: GroupsWireframeProtocol {
    
    weak var viewController: UIViewController?
    weak var baseViewController: UIViewController?
    
    static func initModule(_ viewController: GroupsViewController) {
        // Change to get view from storyboard if not using progammatic UI
        let interactor = GroupsInteractor()
        let router = GroupsRouter()
        let presenter = GroupsPresenter(interface: viewController, interactor: interactor, router: router)
        
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