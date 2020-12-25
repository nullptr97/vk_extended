//
//  NewsfeedInteractor.swift
//  vkExtended
//
//  Created Ярослав Стрельников on 26.10.2020.
//  Copyright © 2020 ExtendedTeam. All rights reserved.
//
import UIKit
import Alamofire
import SwiftyJSON

class NewsfeedInteractor: NewsfeedInteractorProtocol {

    weak var presenter: NewsfeedPresenterProtocol?
    private var revealedPostIds = [Int]()
    private var feedResponse: FeedResponse?
    private var countOffset: Int = 0
    private var isRequesting: Bool = false

    func start(request: Newsfeed.Model.Request.RequestType) {
        makeRequest(request: request)
    }

    func makeRequest(request: Newsfeed.Model.Request.RequestType) {
        guard !isRequesting else { return }
        switch request {
        case .getNewsfeed:
            isRequesting = true
            self.presenter?.presentData(response: .presentFooterLoader)
            presenter?.presentData(response: .presentFooterLoader)
            do {
                try Api.Execute.getNewsfeedSmart().done { [weak self] newsfeedResponse in
                    guard let self = self else { return }
                    self.feedResponse = newsfeedResponse
                    self.presenter?.presentData(response: .presentNewsfeed(feed: newsfeedResponse, revealdedPostIds: self.revealedPostIds))
                    self.isRequesting = false
                }.catch { [weak self] error in
                    guard let self = self else { return }
                    self.presenter?.presentData(response: .presentFooterError(message: error.toVK().toApi()?.message ?? ""))
                    self.isRequesting = false
                }
            } catch {
                self.presenter?.presentData(response: .presentFooterError(message: error.localizedDescription))
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
            guard let feedResponse = feedResponse else { return }
            self.presenter?.presentData(response: .presentNewsfeed(feed: feedResponse, revealdedPostIds: self.revealedPostIds))
        case .getNextBatch:
            self.presenter?.presentData(response: .presentFooterLoader)
            presenter?.presentData(response: .presentFooterLoader)
            do {
                try Api.Newsfeed.get(startFrom: feedResponse?.nextFrom ?? "").done { [weak self] response in
                    guard let self = self else { return }
                    if self.feedResponse == nil {
                        self.feedResponse = response
                    } else {
                        self.feedResponse?.items.append(contentsOf: response.items)
                        
                        var profiles = response.profiles
                        if let oldProfiles = self.feedResponse?.profiles {
                            let oldProfilesFiltered = oldProfiles.filter({ (oldProfile) -> Bool in
                                !response.profiles.contains(where: { $0.id == oldProfile.id })
                            })
                            profiles.append(contentsOf: oldProfilesFiltered)
                        }
                        self.feedResponse?.profiles = profiles
                        
                        var groups = response.groups
                        if let oldGroups = self.feedResponse?.groups {
                            let oldGroupsFiltered = oldGroups.filter({ (oldGroup) -> Bool in
                                !response.groups.contains(where: { $0.id == oldGroup.id })
                            })
                            groups.append(contentsOf: oldGroupsFiltered)
                        }
                        self.feedResponse?.groups = groups
                    }
                    
                    guard let feedResponse = self.feedResponse else { return }
                    self.presenter?.presentData(response: .presentNewsfeed(feed: feedResponse, revealdedPostIds: self.revealedPostIds))
                }.catch { [weak self] error in
                    guard let self = self else { return }
                    self.presenter?.presentData(response: .presentFooterError(message: error.toVK().toApi()?.message ?? ""))
                }
            } catch {
                self.presenter?.presentData(response: .presentFooterError(message: error.localizedDescription))
            }
            
        case .getSuggestions:
            break
        case .like(postId: let postId, sourceId: let sourceId, type: let type):
            do {
                try Api.Likes.add(postId: postId, sourceId: sourceId, type: type).done { [weak self] likesCount in
                    guard let self = self, let feedResponse = self.feedResponse else { return }
                    let post = feedResponse.items.filter { $0.postId == postId }.first
                    post?.likes?.count = likesCount
                    post?.likes?.userLikes = 1
                    self.presenter?.presentData(response: .presentNewsfeed(feed: feedResponse, revealdedPostIds: self.revealedPostIds))
                }.catch { [weak self] error in
                    guard let self = self else { return }
                    self.presenter?.presentData(response: .presentFooterError(message: error.localizedDescription))
                }
            } catch {
                self.presenter?.presentData(response: .presentFooterError(message: error.localizedDescription))
            }
            
        case .unlike(postId: let postId, sourceId: let sourceId, type: let type):
            do {
                try Api.Likes.delete(postId: postId, sourceId: sourceId, type: type).done { [weak self] likesCount in
                    guard let self = self, let feedResponse = self.feedResponse else { return }
                    let post = feedResponse.items.filter { $0.postId == postId }.first
                    post?.likes?.count = likesCount
                    post?.likes?.userLikes = 0
                    self.presenter?.presentData(response: .presentNewsfeed(feed: feedResponse, revealdedPostIds: self.revealedPostIds))
                }.catch { [weak self] error in
                    guard let self = self else { return }
                    self.presenter?.presentData(response: .presentFooterError(message: error.localizedDescription))
                }
            } catch {
                self.presenter?.presentData(response: .presentFooterError(message: error.localizedDescription))
            }
            
        default:
            break
        }
    }
}
