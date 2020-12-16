//
//  FriendsProtocols.swift
//  vkExtended
//
//  Created Ярослав Стрельников on 26.10.2020.
//  Copyright © 2020 ___ORGANIZATIONNAME___. All rights reserved.
//
import Foundation

//MARK: Wireframe -
protocol FriendsWireframeProtocol: class {
    func openProfile(from userId: Int)
}
//MARK: Presenter -
protocol FriendsPresenterProtocol: class {
    func start(request: FriendModel.Request.RequestType)
    func presentData(response: FriendModel.Response.ResponseType)
    func onTapFriend(from userId: Int)
    func onEvent(message: String, isError: Bool)
}

//MARK: Interactor -
protocol FriendsInteractorProtocol: class {
    var presenter: FriendsPresenterProtocol?  { get set }
    func start(request: FriendModel.Request.RequestType)
    func makeRequest(request: FriendModel.Request.RequestType)
}

//MARK: View -
protocol FriendsViewProtocol: class {
    var presenter: FriendsPresenterProtocol?  { get set }
    func displayData(viewModel: FriendModel.ViewModel.ViewModelData)
    func event(message: String, isError: Bool)
}
