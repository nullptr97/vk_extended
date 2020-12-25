//
//  GroupsProtocols.swift
//  vkExtended
//
//  Created Ярослав Стрельников on 26.10.2020.
//  Copyright © 2020 ___ORGANIZATIONNAME___. All rights reserved.
//
import Foundation

//MARK: Wireframe -
protocol GroupsWireframeProtocol: class {
    func openProfile(from userId: Int)
}
//MARK: Presenter -
protocol GroupsPresenterProtocol: class {
    func start(request: Groups.Model.Request.RequestType)
    func presentData(response: Groups.Model.Response.ResponseType)
    func onTapFriend(from userId: Int)
    func onEvent(message: String, isError: Bool)
}

//MARK: Interactor -
protocol GroupsInteractorProtocol: class {
    var presenter: GroupsPresenterProtocol?  { get set }
    func start(request: Groups.Model.Request.RequestType)
    func makeRequest(request: Groups.Model.Request.RequestType)
}

//MARK: View -
protocol GroupsViewProtocol: class {
    var presenter: GroupsPresenterProtocol?  { get set }
    func displayData(viewModel: Groups.Model.ViewModel.ViewModelData)
    func event(message: String, isError: Bool)
}
