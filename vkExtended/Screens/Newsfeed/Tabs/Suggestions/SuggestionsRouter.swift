//
//  SuggestionsRouter.swift
//  VKExt
//
//  Created programmist_NA on 12.07.2020.
//  Copyright © 2020 ExtendedTeam. All rights reserved.
//
import UIKit

class SuggestionsRouter: SuggestionsWireframeProtocol {
    
    weak var viewController: UIViewController?
    weak var baseViewController: UIViewController?
    
    class func createModule(_ viewController: SuggestionsViewController) {
        // Change to get view from storyboard if not using progammatic UI
        let interactor = SuggestionsInteractor()
        let router = SuggestionsRouter()
        let presenter = SuggestionsPresenter(interface: viewController, interactor: interactor, router: router)
        
        viewController.presenter = presenter
        interactor.presenter = presenter
        router.viewController = viewController
        presenter.interactor = interactor
        router.baseViewController = viewController
    }
}
