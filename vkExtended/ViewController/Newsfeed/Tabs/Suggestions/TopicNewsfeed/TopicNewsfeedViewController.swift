//
//  TopicNewsfeedViewController.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 04.12.2020.
//

import UIKit
import IGListKit
import Material
import Alamofire
import SwiftyJSON

struct Topic {
    var id: Int
    var name: String
    var index: Int
}

class TopicNewsfeedViewController: UIViewController {
    var topic: Topic
    
    private var feedResponse: FeedResponse?
    private var revealedPostIds = [Int]()
    private var isRequesting: Bool = false
    
    let mainCollection = CollectionView(frame: .zero, collectionViewLayout: ListCollectionViewLayout(stickyHeaders: false, topContentInset: 0, stretchToEdge: false))
    lazy var adapter: ListAdapter = {
        let listAdapter = ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 1)
        listAdapter.collectionView = mainCollection
        listAdapter.dataSource = self
        return listAdapter
    }()
    private var feedViewModel: FeedViewModel = FeedViewModel.init(cells: [], footerTitle: nil)
    var data = [ListDiffable]()
    var sourceIds: String = ""
    
    var feedIsLoaded: Bool {
        return !feedViewModel.cells.isEmpty
    }
    
    init(with topic: Topic) {
        self.topic = topic
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        
        prepareCollection()
        setupCollection()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard !feedIsLoaded else { return }
        
        getTopicSources(from: topic.id) { [weak self] (sourceIds) in
            guard let self = self else { return }
            self.sourceIds = sourceIds
            
            self.mainCollection.refreshHeader?.start()
        } errorHandler: { [weak self] (errorMessage) in
            guard let self = self else { return }
            self.displayData(viewModel: .displayFooterError(message: errorMessage))
        }
    }
    
    // Подготовка коллекции
    func prepareCollection() {
        view.addSubview(mainCollection)
        mainCollection.autoPinEdge(toSuperviewSafeArea: .top, withInset: 16)
        mainCollection.autoPinEdge(.bottom, to: .bottom, of: view)
        mainCollection.autoPinEdge(.trailing, to: .trailing, of: view)
        mainCollection.autoPinEdge(.leading, to: .leading, of: view)
        mainCollection.backgroundColor = .getThemeableColor(fromNormalColor: .white)
        mainCollection.contentInset.bottom = 0
    }
    
    // Настройка коллекции
    func setupCollection() {
        mainCollection.keyboardDismissMode = .onDrag
        mainCollection.allowsMultipleSelection = true
        
        mainCollection.addRefreshHeader { [weak self] (footer) in
            guard let self = self else { return }

            if self.topic.id == 100 {
                self.makeRequest(request: .getSuggestions)
            } else {
                self.makeRequest(request: .getNewsfeed(sourceIds: self.sourceIds))
            }
        }
        
        mainCollection.addRefreshFooter { [weak self] (footer) in
            if self == nil {
                return
            }
        }
    }
    
    func displayData(feedViewModel: FeedViewModel) {
        self.feedViewModel = feedViewModel
        data = feedViewModel.cells
        
        adapter.reloadData { [weak self] (updated) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.mainCollection.reloadData()
                self.mainCollection.refreshHeader?.success(withDelay: 1)
                self.mainCollection.refreshFooter?.success(withDelay: 1)
            }
        }
    }
}
extension TopicNewsfeedViewController {
    func getTopicSources(from topicId: Int, completionHandler: @escaping ((String) -> Void), errorHandler: @escaping ((String) -> Void)) {
        do {
            try Api.Newsfeed.getUserTopicSources(topicId: topic.id).done { sources in
                let stringSources = sources.compactMap { $0.string }.joined(separator: ",")
                completionHandler(stringSources)
            }.catch { error in
                errorHandler(error.toVK().toApi()?.message ?? "")
            }
        } catch {
            errorHandler(error.localizedDescription)
        }
    }
    
    func makeRequest(request: Newsfeed.Model.Request.RequestType) {
        guard !isRequesting else { return }
        switch request {
        case .getNewsfeed(sourceIds: let ids):
            isRequesting = true
            self.presentData(response: .presentFooterLoader)
            presentData(response: .presentFooterLoader)
            try! Api.Newsfeed.get(sourceIds: ids).done { [weak self] newsfeedResponse in
                guard let self = self else { return }
                self.feedResponse = newsfeedResponse
                self.presentData(response: .presentSuggestions(feed: newsfeedResponse, revealdedPostIds: self.revealedPostIds))
                self.isRequesting = false
            }.catch { [weak self] error in
                guard let self = self else { return }
                self.presentData(response: .presentFooterError(message: error.toVK().toApi()?.message ?? ""))
                self.isRequesting = false
            }
        case .getSuggestions:
            isRequesting = true
            presentData(response: .presentFooterLoader)

            try! Api.Newsfeed.getRecommended().done { response in
                self.presentData(response: .presentSuggestions(feed: response, revealdedPostIds: self.revealedPostIds))
                self.isRequesting = false
            }.catch { error in
                self.presentData(response: .presentFooterError(message: error.toVK().toApi()?.message ?? ""))
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
            self.presentData(response: .presentSuggestions(feed: feedResponse, revealdedPostIds: self.revealedPostIds))
        case .getNextBatch:
            self.presentData(response: .presentFooterLoader)
            let parameters: Alamofire.Parameters = [
                Parameter.fields.rawValue: Constants.userFields,
                Parameter.startFrom.rawValue: feedResponse?.nextFrom ?? ""
            ]
            presentData(response: .presentFooterLoader)
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
                    self.presentData(response: .presentSuggestions(feed: feedResponse, revealdedPostIds: self.revealedPostIds))
                case .error(let error):
                    self.presentData(response: .presentFooterError(message: error.toVK().localizedDescription))
                }
                
            }.catch { error in
                self.presentData(response: .presentFooterError(message: error.localizedDescription))
            }
        case .like(postId: let postId, sourceId: let sourceId, type: let type):
            do {
                try Api.Likes.add(postId: postId, sourceId: sourceId, type: type).done { [weak self] likesCount in
                    guard let self = self, let feedResponse = self.feedResponse else { return }
                    let post = feedResponse.items.filter { $0.postId == postId }.first
                    post?.likes?.count = likesCount
                    post?.likes?.userLikes = 1
                    self.presentData(response: .presentNewsfeed(feed: feedResponse, revealdedPostIds: self.revealedPostIds))
                }.catch { [weak self] error in
                    guard let self = self else { return }
                    self.presentData(response: .presentFooterError(message: error.localizedDescription))
                }
            } catch {
                self.presentData(response: .presentFooterError(message: error.localizedDescription))
            }
        case .unlike(postId: let postId, sourceId: let sourceId, type: let type):
            do {
                try Api.Likes.delete(postId: postId, sourceId: sourceId, type: type).done { [weak self] likesCount in
                    guard let self = self, let feedResponse = self.feedResponse else { return }
                    let post = feedResponse.items.filter { $0.postId == postId }.first
                    post?.likes?.count = likesCount
                    post?.likes?.userLikes = 0
                    self.presentData(response: .presentNewsfeed(feed: feedResponse, revealdedPostIds: self.revealedPostIds))
                }.catch { [weak self] error in
                    guard let self = self else { return }
                    self.presentData(response: .presentFooterError(message: error.localizedDescription))
                }
            } catch {
                self.presentData(response: .presentFooterError(message: error.localizedDescription))
            }
        default:
            break
        }
    }

    func presentData(response: Newsfeed.Model.Response.ResponseType) {
        switch response {
        case .presentSuggestions(let feed, let revealdedPostIds):
            let suggestionCells = feed.items.filter { $0.type != "ads" && $0.type != "user_rec" && !$0.markedAsAds && $0.copyright == nil }.compactMap { (feedItem) in
                cellViewModel(from: feedItem, profiles: feed.profiles, groups: feed.groups, revealdedPostIds: revealdedPostIds)
            }
            
            let feedViewModel = FeedViewModel.init(cells: suggestionCells, footerTitle: nil)
            DispatchQueue.main.async {
                self.displayData(viewModel: .displayNewsfeed(feedViewModel: feedViewModel))
            }
        case .presentFooterLoader:
            DispatchQueue.main.async {
                self.displayData(viewModel: .displayFooterLoader)
            }
        default:
            break
        }
    }
    
    func displayData(viewModel: Newsfeed.Model.ViewModel.ViewModelData) {
        switch viewModel {
        case .displayNewsfeed(let feedViewModel):
            self.feedViewModel = feedViewModel
            data = feedViewModel.cells
            
            adapter.reloadData { [weak self] (updated) in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.mainCollection.reloadData()
                    self.mainCollection.refreshHeader?.success(withDelay: 1)
                    self.mainCollection.refreshFooter?.success(withDelay: 1)
                }
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
        let dateTitle = StdService.instance.postDate(with: date).string(from: date)
        
        let isFullSized = revealdedPostIds.contains { (postId) -> Bool in
            return postId == feedItem.postId
        }

        let sizes = StdService.instance.cellLayoutCalculator.sizes(postText: feedItem.text, repostText: nil, photoAttachments: photoAttachments, isFullSizedPost: isFullSized)
        
        let postText = feedItem.text?.replacingOccurrences(of: "<br>", with: "\n")
        
        if let repost = feedItem.copyHistory?.first {
            let profileRepost = AttachmentsService.instance.profile(for: repost.ownerId, profiles: profiles, groups: groups)
            let repostPhotoAttachments = AttachmentsService.instance.attachments(repostItem: repost)
            let repostAudioAttachments = AttachmentsService.instance.audioAttachments(repostItem: repost)
            let repostEventAttachments = AttachmentsService.instance.eventAttachments(repostItem: repost, profileRepost: profileRepost)

            let repostText = repost.text?.replacingOccurrences(of: "<br>", with: "\n")
            let date = Date(timeIntervalSince1970: repost.date)
            let dateTitle = StdService.instance.postDate(with: date).string(from: date)
            
            let feedRepostCellViewModel = FeedViewModel.FeedRepost.init(id: repost.id, ownerId: repost.ownerId, type: repost.postType, iconUrlString: profileRepost.photo, name: profileRepost.name, date: dateTitle, text: repostText, photoAttachements: repostPhotoAttachments, audioAttachments: repostAudioAttachments, eventAttachments: repostEventAttachments)
            
            let isFullSized = revealdedPostIds.contains { (postId) -> Bool in
                return postId == repost.id
            }
            
            let sizes = StdService.instance.cellLayoutCalculator.sizes(postText: feedItem.text, repostText: repost.text, photoAttachments: repostPhotoAttachments, isFullSizedPost: isFullSized)
            
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
extension TopicNewsfeedViewController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return data
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return NewsSectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}
