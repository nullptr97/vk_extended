//
//  SuggestionsInteractor.swift
//  VKExt
//
//  Created programmist_NA on 12.07.2020.
//  Copyright © 2020 ExtendedTeam. All rights reserved.
//
import UIKit
import Alamofire
import SwiftyJSON

class SuggestionsInteractor: SuggestionsInteractorProtocol {
    weak var presenter: SuggestionsPresenterProtocol?

    private var feedResponse: FeedResponse?
    private var revealedPostIds = [Int]()
    private var isRequesting: Bool = false

    func start(request: Newsfeed.Model.Request.RequestType) {
        makeRequest(request: request)
    }
    
    func makeRequest(request: Newsfeed.Model.Request.RequestType) {
        guard !isRequesting else { return }
        switch request {
        case .getTopics:
            isRequesting = true
            try! Api.Newsfeed.getPostTopics().done { [weak self] topics in
                guard let self = self else { return }
                self.presenter?.presentData(response: .presentTopics(topics: topics))
                self.isRequesting = false
            }.catch { error in
                self.presenter?.presentData(response: .presentFooterError(message: error.toVK().toApi()?.message ?? ""))
                self.isRequesting = false
            }
        case .getNewsfeed(sourceIds: let ids):
            isRequesting = true
            self.presenter?.presentData(response: .presentFooterLoader)
            presenter?.presentData(response: .presentFooterLoader)
            try! Api.Newsfeed.get(sourceIds: ids).done { [weak self] newsfeedResponse in
                guard let self = self else { return }
                self.feedResponse = newsfeedResponse
                self.presenter?.presentData(response: .presentSuggestions(feed: newsfeedResponse, revealdedPostIds: self.revealedPostIds))
                self.isRequesting = false
            }.catch { [weak self] error in
                guard let self = self else { return }
                self.presenter?.presentData(response: .presentFooterError(message: error.toVK().toApi()?.message ?? ""))
                self.isRequesting = false
            }
        case .getSuggestions:
            isRequesting = true            
            presenter?.presentData(response: .presentFooterLoader)

            try! Api.Newsfeed.getRecommended().done { response in
                self.presenter?.presentData(response: .presentSuggestions(feed: response, revealdedPostIds: self.revealedPostIds))
                self.isRequesting = false
            }.catch { error in
                self.presenter?.presentData(response: .presentFooterError(message: error.toVK().toApi()?.message ?? ""))
                self.isRequesting = false
            }
        case .revealPostIds(let postId):
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
            let parameters: Alamofire.Parameters = [
                Parameter.fields.rawValue: Constants.userFields,
                Parameter.startFrom.rawValue: feedResponse?.nextFrom ?? ""
            ]
            presenter?.presentData(response: .presentFooterLoader)
            Request.dataRequest(method: ApiMethod.method(from: .newsfeed, with: ApiMethod.NewsFeed.getRecommended), parameters: parameters).done { [weak self] response in
                guard let self = self else { return }
                switch response {
                case .success(let data):
                    let decodedWall = FeedResponse(from: JSON(data))
                    
                    if self.feedResponse == nil {
                        self.feedResponse = decodedWall
                    } else {
                        self.feedResponse?.items.append(contentsOf: decodedWall.items)
                        
                        var profiles = decodedWall.profiles
                        if let oldProfiles = self.feedResponse?.profiles {
                            let oldProfilesFiltered = oldProfiles.filter({ (oldProfile) -> Bool in
                                !decodedWall.profiles.contains(where: { $0.id == oldProfile.id })
                            })
                            profiles.append(contentsOf: oldProfilesFiltered)
                        }
                        self.feedResponse?.profiles = profiles
                        
                        var groups = decodedWall.groups
                        if let oldGroups = self.feedResponse?.groups {
                            let oldGroupsFiltered = oldGroups.filter({ (oldGroup) -> Bool in
                                !decodedWall.groups.contains(where: { $0.id == oldGroup.id })
                            })
                            groups.append(contentsOf: oldGroupsFiltered)
                        }
                        self.feedResponse?.groups = groups
                    }
                    
                    guard let feedResponse = self.feedResponse else { return }
                    self.presenter?.presentData(response: .presentSuggestions(feed: feedResponse, revealdedPostIds: self.revealedPostIds))
                case .error(let error):
                    self.presenter?.presentData(response: .presentFooterError(message: error.toVK().localizedDescription))
                }
                
            }.catch { error in
                self.presenter?.presentData(response: .presentFooterError(message: error.localizedDescription))
            }
        case .like(let postId, let sourceId, let type):
            break//service?.addLikePost(type: type, ownerId: sourceId, itemId: postId)
        case .unlike(let postId, let sourceId, let type):
            break//service?.deleteLikePost(type: type, ownerId: sourceId, itemId: postId)
        default:
            break
        }
    }
}
