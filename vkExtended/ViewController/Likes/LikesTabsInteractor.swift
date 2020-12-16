//
//  LikesTabsInteractor.swift
//  vkExtended
//
//  Created Ярослав Стрельников on 26.10.2020.
//  Copyright © 2020 ExtendedTeam. All rights reserved.
//
import UIKit
import Alamofire
import SwiftyJSON

class LikesTabsInteractor: LikesTabsInteractorProtocol {
    weak var presenter: LikesTabsPresenterProtocol?
    
    func start(request: LikesModel.Request.RequestType) {
        makeRequest(request: request)
    }
       
    func makeRequest(request: LikesModel.Request.RequestType) {
        switch request {
        case .getLikes(postId: let postId, sourceId: let sourceId, type: let type):
            try! Api.Likes.getList(postId: postId, sourceId: sourceId, type: type, friendsOnly: false).done { [weak self] list in
                guard let self = self else { return }
                self.presenter?.presentData(response: .presentLikes(response: list))
            }.catch { [weak self] error in
                guard let self = self else { return }
                self.presenter?.onEvent(message: error.toVK().toApi()?.message ?? error.localizedDescription, isError: true)
            }
        case .getFriendsLikes(postId: let postId, sourceId: let sourceId, type: let type, friendsOnly: let friendsOnly):
            try! Api.Likes.getList(postId: postId, sourceId: sourceId, type: type, friendsOnly: friendsOnly).done { [weak self] list in
                guard let self = self else { return }
                self.presenter?.presentData(response: .presentFriendsLikes(response: list))
            }.catch { [weak self] error in
                guard let self = self else { return }
                self.presenter?.onEvent(message: error.toVK().toApi()?.message ?? error.localizedDescription, isError: true)
            }
        }
    }
}
