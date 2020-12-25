//
//  LikesTabsPresenter.swift
//  vkExtended
//
//  Created Ярослав Стрельников on 26.10.2020.
//  Copyright © 2020 ExtendedTeam. All rights reserved.
//
import UIKit

class LikesTabsPresenter: LikesTabsPresenterProtocol {

    weak private var view: LikesTabsViewProtocol?
    var interactor: LikesTabsInteractorProtocol?
    private let router: LikesTabsWireframeProtocol

    init(interface: LikesTabsViewProtocol, interactor: LikesTabsInteractorProtocol?, router: LikesTabsWireframeProtocol) {
        self.view = interface
        self.interactor = interactor
        self.router = router
    }

    func start(request: LikesModel.Request.RequestType) {
        interactor?.start(request: request)
    }
    
    // Действие при событии
    func onEvent(message: String, isError: Bool = false) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.view?.event(message: message, isError: isError)
        })
    }
    
    func presentData(response: LikesModel.Response.ResponseType) {
        switch response {
        case .presentLikes(response: let response):
            let cells = response.items.compactMap { (item) in
                profileInfoCellViewModel(from: item)
            }
            let profileViewModel = FriendViewModel.init(cell: cells, footerTitle: "", count: 0)
            
            DispatchQueue.main.async {
                self.view?.displayData(viewModel: .displayLikes(profileViewModel: profileViewModel))
            }
        case .presentFriendsLikes(response: let response):
            let cells = response.items.compactMap { (item) in
                profileInfoCellViewModel(from: item)
            }
            let profileViewModel = FriendViewModel.init(cell: cells, footerTitle: "", count: 0)
            
            DispatchQueue.main.async {
                self.view?.displayData(viewModel: .displayFriendsLikes(profileViewModel: profileViewModel))
            }
        }
    }
    
    private func profileInfoCellViewModel(from friend: FriendItem) -> FriendViewModel.Cell {
        let friendCellViewModel = FriendViewModel.Cell(canWriteMessage: friend.canWritePrivateMessage, imageStatusUrl: friend.imageStatusUrl, lastSeen: friend.onlineInfo.lastSeen ?? 0, verified: friend.getVerification().int, onlinePlatform: Platforms.getPlatform(by: friend.onlineInfo.appId ?? 0).rawValue, id: friend.id, firstName: friend.firstName, lastName: friend.lastName, isClosed: friend.isClosed, deactivated: friend.deactivated, sex: friend.sex, screenName: friend.screenName, bdate: friend.bdate, isOnline: friend.onlineInfo.isOnline ?? false, isMobile: friend.onlineInfo.isMobile ?? false, photo100: friend.photo100, city: friend.homeTown, school: friend.schools.first?.name)
        return friendCellViewModel
    }

    func onTapFriend(from userId: Int) {
        router.openProfile(from: userId)
    }
}
