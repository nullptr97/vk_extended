//
//  ProfileProtocols.swift
//  vkExtended
//
//  Created Ярослав Стрельников on 26.10.2020.
//  Copyright © 2020 ExtendedTeam. All rights reserved.
//
import Foundation

//MARK: Wireframe -
protocol ProfileWireframeProtocol: class {

}
//MARK: Presenter -
protocol ProfilePresenterProtocol: class {
    func start(request: ProfileModel.Request.RequestType)
    func presentData(response: ProfileModel.Response.ResponseType)
    func onEvent(message: String, isError: Bool)
}

//MARK: Interactor -
protocol ProfileInteractorProtocol: class {
    var presenter: ProfilePresenterProtocol?  { get set }
    func start(request: ProfileModel.Request.RequestType)
    func makeRequest(request: ProfileModel.Request.RequestType)
}

//MARK: View -
protocol ProfileViewProtocol: class {
    var presenter: ProfilePresenterProtocol?  { get set }
    func displayData(viewModel: ProfileModel.ViewModel.ViewModelData)
    func event(message: String, isError: Bool)
}
