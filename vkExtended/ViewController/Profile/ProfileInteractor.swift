//
//  ProfileInteractor.swift
//  vkExtended
//
//  Created Ярослав Стрельников on 26.10.2020.
//  Copyright © 2020 ExtendedTeam. All rights reserved.
//
import UIKit
import Alamofire
import SwiftyJSON
import JavaScriptCore

class ProfileInteractor: ProfileInteractorProtocol {

    weak var presenter: ProfilePresenterProtocol?
    private var revealedPostIds = [Int]()
    private var wallResponse: WallResponse?
    private var photosResponse: PhotoResponse?
    private var profileResponse: ProfileResponse?
    private var friendResponse: FriendResponse?
    private var countOffset: Int = 0
    private var hasNextWall: Bool = false

    func start(request: ProfileModel.Request.RequestType) {
        makeRequest(request: request)
    }

    func makeRequest(request: ProfileModel.Request.RequestType) {
        switch request {
        case .getProfile(userId: let userId):
            presenter?.presentData(response: .presentFooterLoader)
            if let profileGetterPath = Bundle.main.path(forResource: "ProfileGetter", ofType: "txt") {
                do {
                    let code = try String(contentsOfFile: profileGetterPath, encoding: String.Encoding.utf8).replacingOccurrences(of: "insert_user_id", with: "\(userId)", options: .literal, range: nil).replacingOccurrences(of: "insert_fields", with: "\"\(Constants.userFields)\"", options: .literal, range: nil)

                    try! Api.Execute.getProfilePage(code: code).done { [weak self] response in
                        guard let self = self else { return }
                        self.friendResponse = response.2
                        if response.0.canAccessClosed {
                            try! Api.Wall.get(ownerId: userId).done { [weak self] response in
                                guard let self = self else { return }
                                self.wallResponse = response
                                self.presenter?.presentData(response: .presentProfileWall(wall: response, revealdedPostIds: self.revealedPostIds))
                            }.catch { [weak self] error in
                                guard let self = self else { return }
                                self.presenter?.onEvent(message: error.toVK().toApi()?.message ?? error.localizedDescription, isError: true)
                            }
                        }
                        self.presenter?.presentData(response: .presentProfile(profile: response.0, photos: response.1, friends: response.2))
                    }.catch { [weak self] error in
                        guard let self = self else { return }
                        self.presenter?.onEvent(message: error.toVK().toApi()?.message ?? error.localizedDescription, isError: true)
                    }
                } catch {
                    self.presenter?.onEvent(message: "Код не может быть исполнен", isError: true)
                }
            }
        case .getFriends(userId: let userId):
            guard friendResponse?.count ?? 0 > friendResponse?.items.count ?? 0 else { return }
            let countFriendOffset = friendResponse?.items.count ?? 0
            presenter?.presentData(response: .presentFooterLoader)
            
            try! Api.Friends.get(userId: userId, offset: countFriendOffset).done { [weak self] response in
                guard let self = self else { return }
                if self.friendResponse == nil {
                    self.friendResponse = response
                } else {
                    self.friendResponse?.items.append(contentsOf: response.items)
                }
                guard let friendResponse = self.friendResponse else { return }
                self.presenter?.presentData(response: .presentProfileFriends(friends: friendResponse))
            }.catch { [weak self] error in
                guard let self = self else { return }
                self.presenter?.onEvent(message: error.toVK().toApi()?.message ?? error.localizedDescription, isError: true)
            }
        case .revealPostIds(postId: let postId):
            if revealedPostIds.count > 0 {
                for revealId in revealedPostIds {
                    if revealId != postId {
                        revealedPostIds.append(postId)
                    } else {
                        continue
                    }
                }
            } else {
                revealedPostIds.append(postId)
            }
            guard let wallResponse = wallResponse else { return }
            self.presenter?.presentData(response: .presentProfileWall(wall: wallResponse, revealdedPostIds: revealedPostIds))
        case .getNextBatch(userId: let userId):
            hasNextWall = wallResponse?.count ?? 0 > wallResponse?.items.count ?? 0
            guard hasNextWall else { return }
            countOffset = wallResponse?.items.count ?? 0
            self.presenter?.presentData(response: .presentFooterLoader)
            presenter?.presentData(response: .presentFooterLoader)
            try! Api.Wall.get(ownerId: userId).done { [weak self] response in
                guard let self = self else { return }
                guard self.wallResponse?.items.count != response.count else { return }
                if self.wallResponse == nil {
                    self.wallResponse = response
                } else {
                    self.wallResponse?.items.append(contentsOf: response.items)
                    
                    var profiles = response.profiles
                    if let oldProfiles = self.wallResponse?.profiles {
                        let oldProfilesFiltered = oldProfiles.filter({ (oldProfile) -> Bool in
                            !response.profiles.contains(where: { $0.id == oldProfile.id })
                        })
                        profiles.append(contentsOf: oldProfilesFiltered)
                    }
                    self.wallResponse?.profiles = profiles
                    
                    var groups = response.groups
                    if let oldGroups = self.wallResponse?.groups {
                        let oldGroupsFiltered = oldGroups.filter({ (oldGroup) -> Bool in
                            !response.groups.contains(where: { $0.id == oldGroup.id })
                        })
                        groups.append(contentsOf: oldGroupsFiltered)
                    }
                    self.wallResponse?.groups = groups
                }
                
                guard let wallResponse = self.wallResponse else { return }
                self.presenter?.presentData(response: .presentProfileWall(wall: wallResponse, revealdedPostIds: self.revealedPostIds))
            }.catch { [weak self] error in
                guard let self = self else { return }
                self.presenter?.onEvent(message: error.toVK().toApi()?.message ?? error.localizedDescription, isError: true)
            }
        case .like(postId: let postId, sourceId: let sourceId, type: let type):
            try! Api.Likes.add(postId: postId, sourceId: sourceId, type: type).done { [weak self] likesCount in
                guard let self = self, let wallResponse = self.wallResponse else { return }
                let post = wallResponse.items.filter { $0.id == postId }.first
                post?.likes?.count = likesCount
                post?.likes?.userLikes = 1
                self.presenter?.presentData(response: .presentProfileWall(wall: wallResponse, revealdedPostIds: self.revealedPostIds))
            }.catch { [weak self] error in
                guard let self = self else { return }
                print(error.toVK().toApi()?.message ?? error.localizedDescription)
                self.presenter?.onEvent(message: error.toVK().toApi()?.message ?? error.localizedDescription, isError: true)
            }
        case .unlike(postId: let postId, sourceId: let sourceId, type: let type):
            try! Api.Likes.delete(postId: postId, sourceId: sourceId, type: type).done { [weak self] likesCount in
                guard let self = self, let wallResponse = self.wallResponse else { return }
                let post = wallResponse.items.filter { $0.id == postId }.first
                post?.likes?.count = likesCount
                post?.likes?.userLikes = 0
                self.presenter?.presentData(response: .presentProfileWall(wall: wallResponse, revealdedPostIds: self.revealedPostIds))
            }.catch { [weak self] error in
                guard let self = self else { return }
                print(error.toVK().toApi()?.message ?? error.localizedDescription)
                self.presenter?.onEvent(message: error.toVK().toApi()?.message ?? error.localizedDescription, isError: true)
            }
        }
    }
}
