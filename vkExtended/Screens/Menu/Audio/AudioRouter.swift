//
//  AudioRouter.swift
//  vkExtended
//
//  Created Ярослав Стрельников on 15.11.2020.
//  Copyright © 2020 ExtendedTeam. All rights reserved.
//
import UIKit

class AudioRouter: AudioWireframeProtocol {
    
    weak var viewController: UIViewController?
    weak var baseViewController: UIViewController?
    
    static func initModule(_ viewController: AudioViewController) {
        // Change to get view from storyboard if not using progammatic UI
        let interactor = AudioInteractor()
        let router = AudioRouter()
        let presenter = AudioPresenter(interface: viewController, interactor: interactor, router: router)
        
        viewController.presenter = presenter
        interactor.presenter = presenter
        router.viewController = viewController
        presenter.interactor = interactor
        router.baseViewController = viewController
    }
}
