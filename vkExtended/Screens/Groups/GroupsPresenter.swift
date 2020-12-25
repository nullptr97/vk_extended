//
//  GroupsPresenter.swift
//  vkExtended
//
//  Created Ярослав Стрельников on 26.10.2020.
//  Copyright © 2020 ___ORGANIZATIONNAME___. All rights reserved.
//
import UIKit

class GroupsPresenter: GroupsPresenterProtocol {

    weak private var view: GroupsViewProtocol?
    var interactor: GroupsInteractorProtocol?
    private let router: GroupsWireframeProtocol

    init(interface: GroupsViewProtocol, interactor: GroupsInteractorProtocol?, router: GroupsWireframeProtocol) {
        self.view = interface
        self.interactor = interactor
        self.router = router
    }

    func start(request: Groups.Model.Request.RequestType) {
        interactor?.start(request: request)
    }
    
    // Действие при событии
    func onEvent(message: String, isError: Bool = false) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.view?.event(message: message, isError: isError)
        })
    }
    
    func presentData(response: Groups.Model.Response.ResponseType) {
        switch response {
        case .presentGroups(groups: let response):
            let cells = response.items.compactMap { (item) in
                groupCellViewModel(from: item)
            }
            
            let groupViewModel = GroupViewModel.init(cells: cells, footerTitle: "")
            DispatchQueue.main.async {
                self.view?.displayData(viewModel: .displayGroups(groupsViewModel: groupViewModel))
            }
        case .presentFooterLoader:
            DispatchQueue.main.async {
                self.view?.displayData(viewModel: .displayFooterLoader)
            }
        case .presentFooterError(message: let messageError):
            DispatchQueue.main.async {
                self.view?.displayData(viewModel: .displayFooterError(message: messageError))
            }
        default:
            break
        }
    }
    
    private func groupCellViewModel(from group: GroupItem) -> GroupViewModel.Cell {
        let groupCellViewModel = GroupViewModel.Cell.init(id: group.id, name: group.name, screenName: group.screenName, isClosed: group.isClosed, type: group.type, isAdmin: group.isAdmin, adminLevel: group.adminLevel, isMember: group.isMember, isAdvertiser: group.isAdvertiser, activity: group.activity, photo50: group.photo50, photo100: group.photo100, photo200: group.photo200, verified: group.verified)
        return groupCellViewModel
    }

    func onTapFriend(from userId: Int) {
        router.openProfile(from: userId)
    }
    
    func onTapFriend(from profileViewModel: FriendViewModel) {
        //router.openProfile(from: userId)
    }
}
