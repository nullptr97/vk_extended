//
//  GroupsInteractor.swift
//  vkExtended
//
//  Created Ярослав Стрельников on 26.10.2020.
//  Copyright © 2020 ___ORGANIZATIONNAME___. All rights reserved.
//
import UIKit
import Alamofire
import SwiftyJSON
import AwesomeCache

class GroupsInteractor: GroupsInteractorProtocol {
    weak var presenter: GroupsPresenterProtocol?
    
    private let cache = try! Cache<NSData>(name: "groupsCache")
    
    func start(request: Groups.Model.Request.RequestType) {
        makeRequest(request: request)
    }
       
    func makeRequest(request: Groups.Model.Request.RequestType) {
        switch request {
        case .getGroups:
            if let profileCache = cache["groups"] as Data? {
                let response = GroupResponse(from: profileCache.json())
                presenter?.presentData(response: .presentGroups(groups: response))
            } else {
                presenter?.presentData(response: .presentFooterLoader)
            }
            
            do {
                try Api.Execute.groupsGet(count: 50).done { [weak self] groupsResponse in
                    guard let self = self else { return }
                    self.presenter?.presentData(response: .presentGroups(groups: groupsResponse))
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
