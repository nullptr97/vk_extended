//
//  ServicesMenuProtocols.swift
//  vkExtended
//
//  Created Ярослав Стрельников on 15.11.2020.
//  Copyright © 2020 ExtendedTeam. All rights reserved.
//
import Foundation

//MARK: Wireframe -
protocol ServicesMenuWireframeProtocol: class {

}
//MARK: Presenter -
protocol ServicesMenuPresenterProtocol: class {
    func onGetSuperApp(lat: Double?, lon: Double?)
    func onPresent(_ superApp: SuperAppServices)
}

//MARK: Interactor -
protocol ServicesMenuInteractorProtocol: class {
    var presenter: ServicesMenuPresenterProtocol? { get set }
    func getSuperApp(lat: Double?, lon: Double?)
}

//MARK: View -
protocol ServicesMenuViewProtocol: class {
    var presenter: ServicesMenuPresenterProtocol? { get set }
    func display(_ superApp: SuperAppServices)
}
