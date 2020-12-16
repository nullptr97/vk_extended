//
//  FriendsInteractor.swift
//  vkExtended
//
//  Created Ярослав Стрельников on 26.10.2020.
//  Copyright © 2020 ___ORGANIZATIONNAME___. All rights reserved.
//
import UIKit
import Alamofire
import SwiftyJSON

class FriendsInteractor: FriendsInteractorProtocol {
    weak var presenter: FriendsPresenterProtocol?
    private var isRequesting: Bool = false
    
    func start(request: FriendModel.Request.RequestType) {
        makeRequest(request: request)
    }
       
    func makeRequest(request: FriendModel.Request.RequestType) {
        switch request {
        case .getFriend:
            isRequesting = true
            presenter?.presentData(response: .presentFooterLoader)
            do {
                try Api.Friends.get(count: 50).done { [weak self] friendsResponse in
                    guard let self = self else { return }
                    self.presenter?.presentData(response: .presentFriend(response: friendsResponse))
                }.catch { [weak self] error in
                    guard let self = self else { return }
                    self.presenter?.onEvent(message: error.toVK().toApi()?.message ?? error.localizedDescription, isError: true)
                    self.presenter?.presentData(response: .presentFooterError(message: error.toVK().toApi()?.message ?? ""))
                }
            } catch {
                self.presenter?.onEvent(message: error.localizedDescription, isError: true)
            }
        default:
            break
        }
    }
}
