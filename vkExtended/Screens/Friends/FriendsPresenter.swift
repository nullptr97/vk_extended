//
//  FriendsPresenter.swift
//  vkExtended
//
//  Created Ярослав Стрельников on 26.10.2020.
//  Copyright © 2020 ___ORGANIZATIONNAME___. All rights reserved.
//
import UIKit

class FriendsPresenter: FriendsPresenterProtocol {

    weak private var view: FriendsViewProtocol?
    var interactor: FriendsInteractorProtocol?
    private let router: FriendsWireframeProtocol

    init(interface: FriendsViewProtocol, interactor: FriendsInteractorProtocol?, router: FriendsWireframeProtocol) {
        self.view = interface
        self.interactor = interactor
        self.router = router
    }

    func start(request: FriendModel.Request.RequestType) {
        interactor?.start(request: request)
    }
    
    // Действие при событии
    func onEvent(message: String, isError: Bool = false) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.view?.event(message: message, isError: isError)
        })
    }
    
    func presentData(response: FriendModel.Response.ResponseType) {
        switch response {
        case .presentFriend(response: let response):
            var importantCells = response.items.compactMap { (item) in
                friendCellViewModel(from: item)
            }
            
            if importantCells.count > 5 {
                importantCells.removeSubrange(5...importantCells.count - 1)
            }
            
            let importantFriendViewModel = FriendViewModel.init(cell: importantCells, footerTitle: "", count: 0)
            
            let cells = response.items.compactMap { (item) in
                friendCellViewModel(from: item)
            }
            
            let friendViewModel = FriendViewModel.init(cell: cells, footerTitle: "", count: 0)
            DispatchQueue.main.async {
                self.view?.displayData(viewModel: .displayAllFriend(importantFriendViewModel: importantFriendViewModel, friendViewModel: friendViewModel.sort()))
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
    
    private func friendCellViewModel(from friend: FriendItem) -> FriendViewModel.Cell {
        let friendCellViewModel = FriendViewModel.Cell(canWriteMessage: friend.canWritePrivateMessage, imageStatusUrl: friend.imageStatusUrl, lastSeen: friend.onlineInfo.lastSeen ?? 0, verified: friend.getVerification().int, onlinePlatform: Platforms.getPlatform(by: friend.onlineInfo.appId ?? 0).rawValue, id: friend.id, firstName: friend.firstName, lastName: friend.lastName, isClosed: friend.isClosed, deactivated: friend.deactivated, sex: friend.sex, screenName: friend.screenName, bdate: friend.bdate, isOnline: friend.onlineInfo.isOnline ?? false, isMobile: friend.onlineInfo.isMobile ?? false, photo100: friend.photo100, city: friend.homeTown, school: friend.schools.first?.name)
        return friendCellViewModel
    }

    func onTapFriend(from userId: Int) {
        router.openProfile(from: userId)
    }
    
    func onTapFriend(from profileViewModel: FriendViewModel) {
        //router.openProfile(from: userId)
    }
}
