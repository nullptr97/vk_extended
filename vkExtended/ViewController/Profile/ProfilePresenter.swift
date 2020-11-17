//
//  ProfilePresenter.swift
//  vkExtended
//
//  Created Ярослав Стрельников on 26.10.2020.
//  Copyright © 2020 ___ORGANIZATIONNAME___. All rights reserved.
//
//  Template generated by Juanpe Catalán @JuanpeCMiOS
//

import UIKit

class ProfilePresenter: ProfilePresenterProtocol {

    weak private var view: ProfileViewProtocol?
    var interactor: ProfileInteractorProtocol?
    private let router: ProfileWireframeProtocol
    let selfService = SelfService.instance

    init(interface: ProfileViewProtocol, interactor: ProfileInteractorProtocol?, router: ProfileWireframeProtocol) {
        self.view = interface
        self.interactor = interactor
        self.router = router
    }

    func start(request: ProfileModel.Request.RequestType) {
        interactor?.start(request: request)
    }

    func presentData(response: ProfileModel.Response.ResponseType) {
        switch response {
        case .presentProfile(profile: let profile, photos: let photos, friends: let friends, wall: let wall, revealdedPostId: let revealdedPostId):
            guard let profile = profile else { return }
            let profileCell = profileInfoCellViewModel(from: profile)
            let profileViewModel = ProfileViewModel.init(cell: profileCell, footerTitle: "")
            
            var photoViewModels: PhotoViewModel = PhotoViewModel.init(cell: [], footerTitle: "")
            if let photos = photos {
                let photosCells = photos.items?.compactMap { (item) in
                    self.photosViewCellViewModel(from: item)
                }
                photoViewModels = PhotoViewModel.init(cell: photosCells ?? [], footerTitle: "")
            }
            
            var friendsViewModels: FriendViewModel = FriendViewModel.init(cell: [], footerTitle: "")
            if let friends = friends {
                let cells = friends.items?.compactMap { (item) in
                    friendCellViewModel(from: item)
                }
                friendsViewModels = FriendViewModel.init(cell: cells ?? [], footerTitle: "")
            }
            
            var wallViewModel: FeedViewModel = FeedViewModel.init(cells: [], footerTitle: "")
            if let wall = wall, let revealdedPostIds = revealdedPostId {
                let cells = wall.items.map { (wallItem) in cellViewModel(from: wallItem, profiles: wall.profiles, groups: wall.groups, revealdedPostIds: revealdedPostIds) }
                wallViewModel = FeedViewModel.init(cells: cells, footerTitle: "")
            }

            DispatchQueue.main.async {
                self.view?.displayData(viewModel: .displayProfile(profileViewModel: profileViewModel, photosViewModel: photoViewModels, friendsViewModel: friendsViewModels, wallViewModel: wallViewModel))
            }
        case .presentProfileInfo(profile: let response):
            let profileViewModel = ProfileViewModel.init(cell: profileInfoCellViewModel(from: response), footerTitle: "")

            DispatchQueue.main.async {
                self.view?.displayData(viewModel: .displayProfileInfo(profileViewModel: profileViewModel))
            }
        case .presentProfilePhotos(photos: let response):
            var photoViewModels: PhotoViewModel = PhotoViewModel.init(cell: [], footerTitle: "")
            let photosCells = response.items?.compactMap { (item) in
                self.photosViewCellViewModel(from: item)
            }
            photoViewModels = PhotoViewModel.init(cell: photosCells ?? [], footerTitle: "")
            
            DispatchQueue.main.async {
                self.view?.displayData(viewModel: .displayProfilePhotos(photosViewModel: photoViewModels))
            }
        case .presentProfileFriends(friends: let response):
            let cells = response.items?.compactMap { (item) in
                friendCellViewModel(from: item)
            }
            
            let friendViewModel = FriendViewModel.init(cell: cells ?? [], footerTitle: "")
            DispatchQueue.main.async {
                self.view?.displayData(viewModel: .displayProfileFriends(friendsViewModel: friendViewModel))
            }
        case .presentProfileWall(wall: let response, revealdedPostIds: let revealPostId):
            var wallViewModel: FeedViewModel = FeedViewModel.init(cells: [], footerTitle: "")
            let cells = response.items.map { (wallItem) in cellViewModel(from: wallItem, profiles: response.profiles, groups: response.groups, revealdedPostIds: revealPostId) }
            wallViewModel = FeedViewModel.init(cells: cells, footerTitle: "")
            DispatchQueue.main.async {
                self.view?.displayData(viewModel: .displayProfileWall(wallViewModel: wallViewModel))
            }
        case .presentFooterLoader:
            DispatchQueue.main.async {
                self.view?.displayData(viewModel: .displayFooterLoader)
            }
        case .presentFooterError(message: let messageError):
            DispatchQueue.main.async {
                self.view?.displayData(viewModel: .displayFooterError(message: messageError))
            }
        }
    }
    
    private func profileInfoCellViewModel(from response: ProfileResponse) -> ProfileViewModel.Cell {
        var action: FriendAction
        switch response.friendStatus {
        case 0:
            action = response.canSendFriendRequest == 1 ? .notFriend : .notFriendWithNoRequest
        case 1:
            action = .requestSend
        case 2:
            action = .incomingRequest
        case 3:
            action = .isFriend
        default:
            action = .notFriend
        }
        var canWriteMessageAction: ProfileActionType
        if response.canWritePrivateMessage == 0 {
            canWriteMessageAction = .actionFriend
        } else {
            canWriteMessageAction = .actionFriendWithMessage
        }
        let profileInfoCellViewModel = ProfileViewModel.Cell.init(verified: response.verified, counters: response.counters, occupation: response.occupation, isCurrentProfile: response.id == Constants.currentUserId, friendActionType: action, type: canWriteMessageAction, id: response.id, firstName: response.firstName, lastName: response.lastName, isClosed: response.isClosed, canAccessClosed: response.canAccessClosed, canPost: true, blacklisted: false, deactivated: response.deactivated, sex: response.sex, screenName: response.screenName, bdate: response.bdate, isOnline: response.onlineInfo?.isOnline, isMobile: response.onlineInfo?.isMobile, photo100: response.photo100, photoMaxOrig: response.photoMaxOrig, status: response.status, friendsCount: response.counters?.friends, followersCount: response.followersCount, school: response.schools?.first?.name, work: response.occupation?.name, city: response.city?.title, relation: RelationType.getRelationType(with: response.sex ?? 1, relation: response.relation ?? 0), schools: response.schools ?? [], universities: response.universities ?? [], contacts: response.contacts, connections: response.connections, personalInfo: nil)
        return profileInfoCellViewModel
    }
    
    private func photosViewCellViewModel(from photoItem: PhotoItem) -> PhotoViewModel.Cell {
        let photosViewCellViewModel = PhotoViewModel.Cell.init(photoMaxUrl: photoItem.srcMax, photoUrlString: photoItem.srcBIG, width: photoItem.width, height: photoItem.height)
        return photosViewCellViewModel
    }
    
    private func friendCellViewModel(from friend: FriendItem) -> FriendViewModel.Cell {
        let friendCellViewModel = FriendViewModel.Cell.init(canWriteMessage: friend.canWritePrivateMessage, lastSeen: friend.onlineInfo?.lastSeen ?? 0, onlinePlatform: Platforms.getPlatform(by: friend.onlineInfo?.appId ?? 0).rawValue, id: friend.id, firstName: friend.firstName, lastName: friend.lastName, isClosed: friend.isClosed, isOnline: friend.onlineInfo?.isOnline, isMobile: friend.onlineInfo?.isMobile, photo100: friend.photo100, school: friend.schools?[0].name, homeTown: friend.homeTown)
        return friendCellViewModel
    }
    
    private func cellViewModel(from wallItem: WallItem, profiles: [Profile], groups: [Group], revealdedPostIds: [Int]) -> FeedViewModel.Cell {
        let profile = AttachmentsService.instance.profile(for: wallItem.ownerId, profiles: profiles, groups: groups)
        
        let attachments = AttachmentsService.instance.attachments(wallItem: wallItem)

        let date = Date(timeIntervalSince1970: wallItem.date)
        let dateTitle = selfService.postDate(with: date).string(from: date)
        
        let isFullSized = revealdedPostIds.contains { (postId) -> Bool in
            return postId == wallItem.id
        }

        let sizes = selfService.cellLayoutCalculator.sizes(postText: wallItem.text, photoAttachments: attachments, isFullSizedPost: isFullSized, isRepost: false)
        
        let postText = wallItem.text?.replacingOccurrences(of: "<br>", with: "\n")
        
        if let repost = wallItem.copyHistory?.first {
            let profileRepost = AttachmentsService.instance.profile(for: repost.ownerId, profiles: profiles, groups: groups)
            let repostAttachments = AttachmentsService.instance.attachments(repostItem: repost)

            let repostText = repost.text?.replacingOccurrences(of: "<br>", with: "\n")
            let date = Date(timeIntervalSince1970: repost.date)
            let dateTitle = selfService.postDate(with: date).string(from: date)
            
            let feedRepostCellViewModel = FeedViewModel.FeedRepost.init(id: repost.id, ownerId: repost.ownerId, type: repost.postType, iconUrlString: profileRepost.photo, name: profileRepost.name, date: dateTitle, text: repostText, photoAttachements: repostAttachments)
            
            let isFullSized = revealdedPostIds.contains { (postId) -> Bool in
                return postId == repost.id
            }
            
            let sizes = selfService.cellLayoutCalculator.sizes(postText: repost.text, photoAttachments: repostAttachments, isFullSizedPost: isFullSized, isRepost: true)
            
            return FeedViewModel.Cell.init(postId: wallItem.id,
                                           sourceId: repost.ownerId,
                                           type: repost.postType,
                                           iconUrlString: profile.photo,
                                           name: profile.name,
                                           date: dateTitle,
                                           text: postText,
                                           likes: AttachmentsService.instance.formattedCounter(wallItem.likes?.count),
                                           userLikes: wallItem.likes?.userLikes,
                                           comments: AttachmentsService.instance.formattedCounter(wallItem.comments?.count),
                                           shares: AttachmentsService.instance.formattedCounter(wallItem.reposts?.count),
                                           views: AttachmentsService.instance.formattedCounter(wallItem.views?.count),
                                           photoAttachements: attachments,
                                           repost: [feedRepostCellViewModel],
                                           sizes: sizes)
        } else {
            return FeedViewModel.Cell.init(postId: wallItem.id,
                                           sourceId: wallItem.ownerId,
                                           type: wallItem.postType,
                                           iconUrlString: profile.photo,
                                           name: profile.name,
                                           date: dateTitle,
                                           text: postText,
                                           likes: AttachmentsService.instance.formattedCounter(wallItem.likes?.count),
                                           userLikes: wallItem.likes?.userLikes,
                                           comments: AttachmentsService.instance.formattedCounter(wallItem.comments?.count),
                                           shares: AttachmentsService.instance.formattedCounter(wallItem.reposts?.count),
                                           views: AttachmentsService.instance.formattedCounter(wallItem.views?.count),
                                           photoAttachements: attachments,
                                           repost: nil,
                                           sizes: sizes)
        }
    }
}