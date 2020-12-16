//
//  ProfileRouter.swift
//  vkExtended
//
//  Created Ярослав Стрельников on 26.10.2020.
//  Copyright © 2020 ExtendedTeam. All rights reserved.
//
import UIKit

class ProfileRouter: ProfileWireframeProtocol {
    
    weak var viewController: UIViewController?
    weak var baseViewController: UIViewController?
    
    static func initModule(_ viewController: ProfileViewController) {
        // Change to get view from storyboard if not using progammatic UI
        let interactor = ProfileInteractor()
        let router = ProfileRouter()
        let presenter = ProfilePresenter(interface: viewController, interactor: interactor, router: router)
        
        viewController.presenter = presenter
        interactor.presenter = presenter
        router.viewController = viewController
        presenter.interactor = interactor
        router.baseViewController = viewController
    }
}
