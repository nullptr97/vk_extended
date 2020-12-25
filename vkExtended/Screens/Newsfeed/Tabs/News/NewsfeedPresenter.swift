//
//  NewsfeedPresenter.swift
//  vkExtended
//
//  Created Ярослав Стрельников on 26.10.2020.
//  Copyright © 2020 ExtendedTeam. All rights reserved.
//
import UIKit

class NewsfeedPresenter: NewsfeedPresenterProtocol {

    weak private var view: NewsfeedViewProtocol?
    var interactor: NewsfeedInteractorProtocol?
    private let router: NewsfeedWireframeProtocol
    let selfService = StdService.instance

    init(interface: NewsfeedViewProtocol, interactor: NewsfeedInteractorProtocol?, router: NewsfeedWireframeProtocol) {
        self.view = interface
        self.interactor = interactor
        self.router = router
    }

    func start(request: Newsfeed.Model.Request.RequestType) {
        interactor?.start(request: request)
    }

    func presentData(response: Newsfeed.Model.Response.ResponseType) {
        switch response {
        case .presentNewsfeed(feed: let feed, revealdedPostIds: let revealdedPostIds):
            var feedViewModel: FeedViewModel = FeedViewModel.init(cells: [], footerTitle: "")
            let cells = feed.items.filter { $0.type != "ads" && !$0.markedAsAds && $0.copyright == nil }.compactMap { (wallItem) in cellViewModel(from: wallItem, profiles: feed.profiles, groups: feed.groups, revealdedPostIds: revealdedPostIds) }
            feedViewModel = FeedViewModel.init(cells: cells, footerTitle: "")
            DispatchQueue.main.async {
                self.view?.displayData(viewModel: .displayNewsfeed(feedViewModel: feedViewModel))
            }
        case .presentSuggestions(feed: let feed, revealdedPostIds: let revealdedPostIds):
            break
        case .presentFooterLoader:
            DispatchQueue.main.async {
                self.view?.displayData(viewModel: .displayFooterLoader)
            }
        case .presentFooterError(message: let message):
            DispatchQueue.main.async {
                self.view?.displayData(viewModel: .displayFooterError(message: message))
            }
        default:
            break
        }
    }
    
    private func cellViewModel(from feedItem: FeedItem, profiles: [Profile], groups: [Group], revealdedPostIds: [Int]) -> FeedViewModel.Cell {
        let profile = AttachmentsService.instance.profile(for: feedItem.sourceId, profiles: profiles, groups: groups)
        
        let photoAttachments = AttachmentsService.instance.attachments(feedItem: feedItem)
        let audioAttachments = AttachmentsService.instance.audioAttachments(feedItem: feedItem)
        let eventAttachments = AttachmentsService.instance.eventAttachments(feedItem: feedItem, profileFeed: profile)

        let date = Date(timeIntervalSince1970: feedItem.date)
        let dateTitle = selfService.postDate(with: date).string(from: date)
        
        let isFullSized = revealdedPostIds.contains { (postId) -> Bool in
            return postId == feedItem.postId
        }

        let sizes = selfService.cellLayoutCalculator.sizes(postText: feedItem.text, repostText: nil, photoAttachments: photoAttachments, isFullSizedPost: isFullSized)
        
        let postText = feedItem.text?.replacingOccurrences(of: "<br>", with: "\n")
        
        if let repost = feedItem.copyHistory?.first {
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
            
            let sizes = selfService.cellLayoutCalculator.sizes(postText: feedItem.text, repostText: repost.text, photoAttachments: repostPhotoAttachments, isFullSizedPost: isFullSized)
            
            return FeedViewModel.Cell.init(postId: feedItem.postId,
                                           sourceId: repost.ownerId,
                                           type: repost.postType,
                                           iconUrlString: profile.photo,
                                           id: profile.id,
                                           name: profile.name,
                                           date: dateTitle,
                                           text: postText,
                                           likes: AttachmentsService.instance.formattedCounter(feedItem.likes?.count),
                                           userLikes: feedItem.likes?.userLikes,
                                           comments: AttachmentsService.instance.formattedCounter(feedItem.comments?.count),
                                           shares: AttachmentsService.instance.formattedCounter(feedItem.reposts?.count),
                                           views: AttachmentsService.instance.formattedCounter(feedItem.views?.count),
                                           photoAttachements: photoAttachments,
                                           audioAttachments: audioAttachments,
                                           eventAttachments: eventAttachments,
                                           repost: [feedRepostCellViewModel],
                                           sizes: sizes)
        } else {
            return FeedViewModel.Cell.init(postId: feedItem.postId,
                                           sourceId: feedItem.sourceId,
                                           type: feedItem.type,
                                           iconUrlString: profile.photo,
                                           id: profile.id,
                                           name: profile.name,
                                           date: dateTitle,
                                           text: postText,
                                           likes: AttachmentsService.instance.formattedCounter(feedItem.likes?.count),
                                           userLikes: feedItem.likes?.userLikes,
                                           comments: AttachmentsService.instance.formattedCounter(feedItem.comments?.count),
                                           shares: AttachmentsService.instance.formattedCounter(feedItem.reposts?.count),
                                           views: AttachmentsService.instance.formattedCounter(feedItem.views?.count),
                                           photoAttachements: photoAttachments,
                                           audioAttachments: audioAttachments,
                                           eventAttachments: eventAttachments,
                                           repost: nil,
                                           sizes: sizes)
        }
    }
}
