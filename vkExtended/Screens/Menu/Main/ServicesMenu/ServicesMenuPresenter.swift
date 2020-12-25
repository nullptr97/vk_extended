//
//  ServicesMenuPresenter.swift
//  vkExtended
//
//  Created Ярослав Стрельников on 15.11.2020.
//  Copyright © 2020 ExtendedTeam. All rights reserved.
//
import UIKit

class ServicesMenuPresenter: ServicesMenuPresenterProtocol {

    weak private var view: ServicesMenuViewProtocol?
    var interactor: ServicesMenuInteractorProtocol?
    private let router: ServicesMenuWireframeProtocol

    init(interface: ServicesMenuViewProtocol, interactor: ServicesMenuInteractorProtocol?, router: ServicesMenuWireframeProtocol) {
        self.view = interface
        self.interactor = interactor
        self.router = router
    }

    func onGetSuperApp(lat: Double?, lon: Double?) {
        interactor?.getSuperApp(lat: lat, lon: lon)
    }
    
    func onPresent(_ superApp: SuperAppServices) {
        DispatchQueue.main.async {
            self.view?.display(superApp)
        }
    }
}
