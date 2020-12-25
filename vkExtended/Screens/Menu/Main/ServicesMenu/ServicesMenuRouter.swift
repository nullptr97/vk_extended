//
//  ServicesMenuRouter.swift
//  vkExtended
//
//  Created Ярослав Стрельников on 15.11.2020.
//  Copyright © 2020 ExtendedTeam. All rights reserved.
//
import UIKit

class ServicesMenuRouter: ServicesMenuWireframeProtocol {
    
    weak var viewController: UIViewController?
    weak var baseViewController: UIViewController?
    
    static func initModule(_ viewController: ServicesMenuViewController) {
        // Change to get view from storyboard if not using progammatic UI
        let interactor = ServicesMenuInteractor()
        let router = ServicesMenuRouter()
        let presenter = ServicesMenuPresenter(interface: viewController, interactor: interactor, router: router)
        
        viewController.presenter = presenter
        interactor.presenter = presenter
        router.viewController = viewController
        presenter.interactor = interactor
        router.baseViewController = viewController
    }
}