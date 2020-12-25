//
//  ProfilePresenter.swift
//  vkExtended
//
//  Created Ярослав Стрельников on 26.10.2020.
//  Copyright © 2020 ExtendedTeam. All rights reserved.
//
import UIKit

class ProfilePresenter: ProfilePresenterProtocol {

    weak private var view: ProfileViewProtocol?
    var interactor: ProfileInteractorProtocol?
    private let router: ProfileWireframeProtocol
    let selfService = StdService.instance

    init(interface: ProfileViewProtocol, interactor: ProfileInteractorProtocol?, router: ProfileWireframeProtocol) {
        self.view = interface
        self.interactor = interactor
        self.router = router
    }

    func start(request: ProfileModel.Request.RequestType) {
        interactor?.start(request: request)
    }
    
    // Действие при событии
    func onEvent(message: String, isError: Bool = false) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.view?.event(message: message, isError: isError)
        })
    }

    // Показать данные
    func presentData(response: ProfileModel.Response.ResponseType) {
        switch response {
        case .presentProfile(profile: let profile, photos: let photos, friends: let friends):
            guard let profile = profile else { return }
            let profileCell = profileInfoCellViewModel(from: profile)
            let profileViewModel = ProfileViewModel.init(cell: profileCell, footerTitle: "")
            let friendsViewModel: FriendViewModel
            if let friendsResponse = friends {
                friendsViewModel = FriendViewModel.init(cell: friendsResponse.items.compactMap { (friendItem) in friendCellViewModel(from: friendItem) }, footerTitle: "", count: friendsResponse.count ?? 0)
            } else {
                friendsViewModel = FriendViewModel.init(cell: [], footerTitle: "", count: 0)
            }
            
            var photoViewModels: PhotoViewModel = PhotoViewModel.init(cell: [], footerTitle: "", count: 0)
            if let photos = photos {
                let photosCells = photos.items.compactMap { (item) in
                    self.photosViewCellViewModel(from: item)
                }
                photoViewModels = PhotoViewModel.init(cell: photosCells, footerTitle: "", count: photos.count)
            }

            DispatchQueue.main.async {
                self.view?.displayData(viewModel: .displayProfile(profileViewModel: profileViewModel, photosViewModel: photoViewModels, friendsViewModel: friendsViewModel))
            }
        case .presentProfileFriends(friends: let response):
            let friendsViewModel: FriendViewModel = FriendViewModel.init(cell: response.items.map { (friendItem) in friendCellViewModel(from: friendItem) }, footerTitle: "", count: response.count ?? 0)
            DispatchQueue.main.async {
                self.view?.displayData(viewModel: .displayProfileFriends(friendsViewModel: friendsViewModel))
            }
        case .presentProfileWall(wall: let response, revealdedPostIds: let revealPostId):
            let wallViewModel: FeedViewModel = FeedViewModel.init(cells: response.items.filter { $0.id != 0 && $0.ownerId != 0 }.map { (wallItem) in cellViewModel(from: wallItem, profiles: response.profiles, groups: response.groups, revealdedPostIds: revealPostId) }, footerTitle: "")
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

        let profileInfoCellViewModel = ProfileViewModel.Cell.init(
            imageStatusUrl: response.imageStatus?.images.first?.url,
            verified: response.verified,
            counters: response.counters,
            occupation: response.occupation,
            isCurrentProfile: response.id == currentUserId,
            friendActionType: action, type: canWriteMessageAction,
            id: response.id,
            firstNameNom: response.firstNameNom, lastNameNom: response.lastNameNom,
            firstNameGen: response.firstNameGen, lastNameGen: response.lastNameGen,
            firstNameDat: response.firstNameDat, lastNameDat: response.lastNameDat,
            firstNameAcc: response.firstNameAcc, lastNameAcc: response.lastNameAcc,
            firstNameIns: response.firstNameIns, lastNameIns: response.lastNameIns,
            firstNameAbl: response.firstNameAbl, lastNameAbl: response.lastNameAbl,
            isClosed: response.isClosed, canAccessClosed: response.canAccessClosed, canPost: response.canPost?.boolValue,
            blacklisted: response.blacklisted?.boolValue, deactivated: response.deactivated,
            sex: response.sex,
            screenName: response.screenName, bdate: response.bdate,
            lastSeen: response.onlineInfo.lastSeen ?? 0, onlinePlatform: Platforms.getPlatform(by: response.onlineInfo.appId ?? 0).rawValue,
            isOnline: response.onlineInfo.isOnline ?? false, isMobile: response.onlineInfo.isMobile ?? false,
            photo100: response.photo100, photoMaxOrig: response.photoMaxOrig,
            status: response.status,
            friendsCount: response.counters?.friends, followersCount: response.followersCount,
            school: response.schools?.first?.name, work: response.occupation?.name, city: response.city?.title,
            relation: RelationType.getRelationType(with: response.sex, relation: response.relation ?? 0),
            schools: response.schools ?? [], universities: response.universities ?? [],
            contacts: response.contacts, connections: response.connections,
            personalInfo: nil)
        return profileInfoCellViewModel
    }
    
    private func photosViewCellViewModel(from photoItem: PhotoItem) -> PhotoViewModel.Cell {
        let photosViewCellViewModel = PhotoViewModel.Cell.init(photoMaxUrl: photoItem.srcMax, photoUrlString: photoItem.srcBIG, width: photoItem.width, height: photoItem.height)
        return photosViewCellViewModel
    }
    
    private func friendCellViewModel(from friend: FriendItem) -> FriendViewModel.Cell {
        let friendCellViewModel = FriendViewModel.Cell(canWriteMessage: friend.canWritePrivateMessage, imageStatusUrl: friend.imageStatusUrl, lastSeen: friend.onlineInfo.lastSeen ?? 0, verified: friend.getVerification().int, onlinePlatform: Platforms.getPlatform(by: friend.onlineInfo.appId ?? 0).rawValue, id: friend.id, firstName: friend.firstName, lastName: friend.lastName, isClosed: friend.isClosed, deactivated: friend.deactivated, sex: friend.sex, screenName: friend.screenName, bdate: friend.bdate, isOnline: friend.onlineInfo.isOnline ?? false, isMobile: friend.onlineInfo.isMobile ?? false, photo100: friend.photo100, city: friend.homeTown, school: friend.schools.first?.name)
        return friendCellViewModel
    }
    
    private func cellViewModel(from wallItem: WallItem, profiles: [Profile], groups: [Group], revealdedPostIds: [Int]) -> FeedViewModel.Cell {
        let profile = AttachmentsService.instance.profile(for: wallItem.ownerId, profiles: profiles, groups: groups)
        
        let photoAttachments = AttachmentsService.instance.attachments(wallItem: wallItem)
        let audioAttachments = AttachmentsService.instance.audioAttachments(wallItem: wallItem)
        let eventAttachments = AttachmentsService.instance.eventAttachments(wallItem: wallItem, profileWallItem: profile)

        let date = Date(timeIntervalSince1970: wallItem.date)
        let dateTitle = selfService.postDate(with: date).string(from: date)
        
        let isFullSized = revealdedPostIds.contains { (postId) -> Bool in
            return postId == wallItem.id
        }

        let sizes = selfService.cellLayoutCalculator.sizes(postText: wallItem.text, repostText: nil, photoAttachments: photoAttachments, isFullSizedPost: isFullSized)
        
        let postText = wallItem.text?.replacingOccurrences(of: "<br>", with: "\n")
        
        if let repost = wallItem.copyHistory?.first {
            let profileRepost = AttachmentsService.instance.profile(for: repost.ownerId, profiles: profiles, groups: groups)

            let repostPhotoAttachments = AttachmentsService.instance.attachments(repostItem: repost)
            let repostAudioAttachments = AttachmentsService.instance.audioAttachments(repostItem: repost)
            let repostEventAttachments = AttachmentsService.instance.eventAttachments(repostItem: repost, profileRepost: profileRepost)

            let repostText = repost.text?.replacingOccurrences(of: "<br>", with: "\n")
            let date = Date(timeIntervalSince1970: repost.date)
            let dateTitle = selfService.postDate(with: date).string(from: date)
            
            let feedRepostCellViewModel = FeedViewModel.FeedRepost.init(id: repost.id, ownerId: repost.ownerId, type: repost.postType, iconUrlString: profileRepost.photo, name: profileRepost.name, date: dateTitle, text: repostText, photoAttachements: repostPhotoAttachments, audioAttachments: repostAudioAttachments, eventAttachments: repostEventAttachments)
            
            let isFullSized = revealdedPostIds.contains { (postId) -> Bool in
                return postId == repost.id
            }
            
            let sizes = selfService.cellLayoutCalculator.sizes(postText: wallItem.text, repostText: repost.text, photoAttachments: repostPhotoAttachments, isFullSizedPost: isFullSized)
            
            return FeedViewModel.Cell.init(postId: wallItem.id,
                                           sourceId: repost.ownerId,
                                           type: repost.postType,
                                           iconUrlString: profile.photo,
                                           id: profile.id,
                                           name: profile.name,
                                           date: dateTitle,
                                           text: postText,
                                           likes: AttachmentsService.instance.formattedCounter(wallItem.likes?.count),
                                           userLikes: wallItem.likes?.userLikes,
                                           comments: AttachmentsService.instance.formattedCounter(wallItem.comments?.count),
                                           shares: AttachmentsService.instance.formattedCounter(wallItem.reposts?.count),
                                           views: AttachmentsService.instance.formattedCounter(wallItem.views?.count),
                                           photoAttachements: photoAttachments,
                                           audioAttachments: audioAttachments,
                                           eventAttachments: eventAttachments,
                                           repost: [feedRepostCellViewModel],
                                           sizes: sizes)
        } else {
            return FeedViewModel.Cell.init(postId: wallItem.id,
                                           sourceId: wallItem.ownerId,
                                           type: wallItem.postType,
                                           iconUrlString: profile.photo,
                                           id: profile.id,
                                           name: profile.name,
                                           date: dateTitle,
                                           text: postText,
                                           likes: AttachmentsService.instance.formattedCounter(wallItem.likes?.count),
                                           userLikes: wallItem.likes?.userLikes,
                                           comments: AttachmentsService.instance.formattedCounter(wallItem.comments?.count),
                                           shares: AttachmentsService.instance.formattedCounter(wallItem.reposts?.count),
                                           views: AttachmentsService.instance.formattedCounter(wallItem.views?.count),
                                           photoAttachements: photoAttachments,
                                           audioAttachments: audioAttachments,
                                           eventAttachments: eventAttachments,
                                           repost: nil,
                                           sizes: sizes)
        }
    }
}
