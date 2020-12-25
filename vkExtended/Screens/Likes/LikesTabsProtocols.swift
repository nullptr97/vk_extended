//
//  LikesTabsProtocols.swift
//  vkExtended
//
//  Created Ярослав Стрельников on 26.10.2020.
//  Copyright © 2020 ExtendedTeam. All rights reserved.
//
import Foundation

//MARK: Wireframe -
protocol LikesTabsWireframeProtocol: class {
    func openProfile(from userId: Int)
}
//MARK: Presenter -
protocol LikesTabsPresenterProtocol: class {
    func start(request: LikesModel.Request.RequestType)
    func presentData(response: LikesModel.Response.ResponseType)
    func onTapFriend(from userId: Int)
    func onEvent(message: String, isError: Bool)
}

//MARK: Interactor -
protocol LikesTabsInteractorProtocol: class {
    var presenter: LikesTabsPresenterProtocol?  { get set }
    func start(request: LikesModel.Request.RequestType)
    func makeRequest(request: LikesModel.Request.RequestType)
}

//MARK: View -
protocol LikesTabsViewProtocol: class {
    var presenter: LikesTabsPresenterProtocol?  { get set }
    func displayData(viewModel: LikesModel.ViewModel.ViewModelData)
    func event(message: String, isError: Bool)
}
