//
//  NewsfeedRouter.swift
//  vkExtended
//
//  Created Ярослав Стрельников on 26.10.2020.
//  Copyright © 2020 ExtendedTeam. All rights reserved.
//
import UIKit

class NewsfeedRouter: NewsfeedWireframeProtocol {
    
    weak var viewController: UIViewController?
    weak var baseViewController: UIViewController?
    
    static func initModule(_ viewController: NewsfeedViewController) {
        // Change to get view from storyboard if not using progammatic UI
        let interactor = NewsfeedInteractor()
        let router = NewsfeedRouter()
        let presenter = NewsfeedPresenter(interface: viewController, interactor: interactor, router: router)
        
        viewController.presenter = presenter
        interactor.presenter = presenter
        router.viewController = viewController
        presenter.interactor = interactor
        router.baseViewController = viewController
    }
}
