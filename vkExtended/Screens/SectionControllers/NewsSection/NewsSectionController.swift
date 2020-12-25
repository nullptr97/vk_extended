//
//  NewsHeaderSectionController.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 21.11.2020.
//

import Foundation
import IGListKit
import Material

class NewsSectionController: ListBindingSectionController<FeedViewModel.Cell>, ListBindingSectionControllerDataSource {
    var results = [ListDiffable]()

    override init() {
        super.init()
        dataSource = self
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, viewModelsFor object: Any) -> [ListDiffable] {
        guard let object = object as? FeedViewModel.Cell else { fatalError() }
        results.append(NewsfeedDividerViewModel())
        results.append(NewsfeedHeaderViewModel(iconUrlString: object.iconUrlString, name: object.name, date: object.date))
        
        if let text = object.text, !text.isEmpty {
            results.append(NewsfeedTextViewModel(text: object.text, isReveal: object.sizes.moreTextButtonFrame.size.height == 0))
        } else {
            results.append(contentsOf: [])
        }
        
        if object.photoAttachements.count > 0 {
            results.append(NewsfeedPhotoAttachmentsViewModel(photoAttachements: object.photoAttachements))
        } else {
            results.append(contentsOf: [])
        }
        if object.audioAttachments.count > 0 {
            results.append(NewsfeedAudioAttachmentsViewModel(audioAttachements: object.audioAttachments))
        } else {
            results.append(contentsOf: [])
        }
        if object.eventAttachments.count > 0 {
            results.append(NewsfeedEventAttachmentsViewModel(eventAttachements: object.eventAttachments))
        }
        
        if let repost = object.repost?.first {
            results.append(RepostHeaderViewModel(iconUrlString: repost.iconUrlString, name: repost.name, date: repost.date))
            if let repostText = repost.text, !repostText.isEmpty {
                results.append(RepostTextViewModel(text: repostText))
            } else {
                results.append(contentsOf: [])
            }
            if repost.photoAttachements.count > 0 {
                results.append(NewsfeedPhotoAttachmentsViewModel(photoAttachements: repost.photoAttachements))
            } else {
                results.append(contentsOf: [])
            }
            if repost.audioAttachments.count > 0 {
                results.append(NewsfeedAudioAttachmentsViewModel(audioAttachements: repost.audioAttachments))
            } else {
                results.append(contentsOf: [])
            }
            if repost.eventAttachments.count > 0 {
                results.append(NewsfeedEventAttachmentsViewModel(eventAttachements: repost.eventAttachments))
            }
        } else {
            results.append(contentsOf: [])
        }

        results.append(NewsfeedFooterViewModel(likes: object.likes, userLikes: object.userLikes, comments: object.comments, shares: object.shares, views: object.views))
        results.append(NewsfeedDividerViewModel())
        
        return results
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, cellForViewModel viewModel: Any, at index: Int) -> UICollectionViewCell & ListBindable {
        let identifier: String
        switch viewModel {
        case is NewsfeedHeaderViewModel:
            identifier = "NewsHeaderCollectionViewCell"
            let cell = collectionContext?.dequeueReusableCell(withNibName: identifier, bundle: nil, for: sectionController, at: index) as! NewsHeaderCollectionViewCell
            return cell
        case is NewsfeedTextViewModel:
            identifier = "NewsfeedTextCollectionViewCell"
            let cell = collectionContext?.dequeueReusableCell(withNibName: identifier, bundle: nil, for: sectionController, at: index) as! NewsfeedTextCollectionViewCell
            cell.delegate = self
            return cell
        case is RepostTextViewModel:
            identifier = "RepostTextCollectionViewCell"
            let cell = collectionContext?.dequeueReusableCell(withNibName: identifier, bundle: nil, for: sectionController, at: index) as! RepostTextCollectionViewCell
            return cell
        case is RepostHeaderViewModel:
            identifier = "RepostHeaderCollectionViewCell"
            let cell = collectionContext?.dequeueReusableCell(withNibName: identifier, bundle: nil, for: sectionController, at: index) as! RepostHeaderCollectionViewCell
            return cell
        case is NewsfeedPhotoAttachmentsViewModel:
            identifier = "NewsfeedPhotoAttachmentsCollectionViewCell"
            let cell = collectionContext?.dequeueReusableCell(withNibName: identifier, bundle: nil, for: sectionController, at: index) as! NewsfeedPhotoAttachmentsCollectionViewCell
            return cell
        case is NewsfeedAudioAttachmentsViewModel:
            identifier = "NewsfeedAudioAttachmentsCollectionViewCell"
            let cell = collectionContext?.dequeueReusableCell(withNibName: identifier, bundle: nil, for: sectionController, at: index) as! NewsfeedAudioAttachmentsCollectionViewCell
            return cell
        case is NewsfeedEventAttachmentsViewModel:
            identifier = "NewsfeedEventAttachmentsCollectionViewCell"
            let cell = collectionContext?.dequeueReusableCell(withNibName: identifier, bundle: nil, for: sectionController, at: index) as! NewsfeedEventAttachmentsCollectionViewCell
            return cell
        case is NewsfeedFooterViewModel:
            identifier = "NewsFooterCollectionViewCell"
            let cell = collectionContext?.dequeueReusableCell(withNibName: identifier, bundle: nil, for: sectionController, at: index) as! NewsFooterCollectionViewCell
            cell.delegate = self
            return cell
        case is NewsfeedDividerViewModel:
            identifier = "DividerCollectionViewCell"
            let cell = collectionContext?.dequeueReusableCell(withNibName: identifier, bundle: nil, for: sectionController, at: index) as! DividerCollectionViewCell
            return cell
        default:
            fatalError()
        }
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, sizeForViewModel viewModel: Any, at index: Int) -> CGSize {
        guard let collectionContext = collectionContext, let object = sectionController.object as? FeedViewModel.Cell else { fatalError() }
        var height: CGFloat
        var width: CGFloat
        switch viewModel {
        case is NewsfeedHeaderViewModel:
            width = collectionContext.containerSize.width
            height = 64
        case is NewsfeedTextViewModel:
            width = collectionContext.containerSize.width
            height = object.sizes.postLabelFrame.size.height + object.sizes.moreTextButtonFrame.size.height
        case is RepostTextViewModel:
            width = collectionContext.containerSize.width
            height = object.sizes.repostLabelFrame.size.height + object.sizes.moreTextButtonFrame.size.height
        case is RepostHeaderViewModel:
            width = collectionContext.containerSize.width
            height = 58
        case is NewsfeedPhotoAttachmentsViewModel:
            width = collectionContext.containerSize.width
            height = screenWidth
        case is NewsfeedAudioAttachmentsViewModel:
            width = collectionContext.containerSize.width
            if let repost = object.repost?.first, repost.audioAttachments.count > 0 {
                height = (repost.audioAttachments.count * 58).cgFloat
            } else {
                height = (object.audioAttachments.count * 58).cgFloat
            }
        case is NewsfeedEventAttachmentsViewModel:
            width = collectionContext.containerSize.width
            height = 152
        case is NewsfeedFooterViewModel:
            width = collectionContext.containerSize.width
            height = 48
        case is NewsfeedDividerViewModel:
            width = collectionContext.containerSize.width - 24
            height = 0.3
        default:
            width = collectionContext.containerSize.width
            height = 0
        }
        return .custom(width, height)
    }
}
extension NewsSectionController: NewsFeedCellDelegate {
    func openLikesList(for cell: UICollectionViewCell & ListBindable) {
        guard
            let postId = object?.postId,
            let sourceId = object?.sourceId,
            let type = object?.type
        else { return }
        viewController?.navigationController?.pushViewController(LikesTabsViewController(viewControllers: [
                                                                                            LikesViewController(postId: postId, sourceId: sourceId, type: type),
                                                                                            FriendsLikesViewController(postId: postId, sourceId: sourceId, type: type)]
        ), animated: true)
    }
    
    func revealPost(for cell: UICollectionViewCell & ListBindable) {
        guard let postId = object?.postId else { return }
        switch viewController {
        case is NewsfeedViewController:
            (viewController as? NewsfeedViewController)?.presenter?.start(request: .revealPostIds(postId: postId))
        case is ProfileViewController:
            (viewController as? ProfileViewController)?.presenter?.start(request: .revealPostIds(postId: postId))
        default:
            break
        }
    }
    
    func likePost(for cell: UICollectionViewCell & ListBindable) {
        guard let postId = object?.postId, let postType = object?.type else { return }
        print(postId, postType)
        switch viewController {
        case is NewsfeedViewController:
            guard let sourceId = object?.sourceId else { return }
            (viewController as? NewsfeedViewController)?.presenter?.start(request: .like(postId: postId, sourceId: sourceId, type: postType))
        case is ProfileViewController:
            guard let sourceId = object?.id else { return }
            (viewController as? ProfileViewController)?.presenter?.start(request: .like(postId: postId, sourceId: sourceId, type: postType))
        default:
            break
        }
    }
    
    func unlikePost(for cell: UICollectionViewCell & ListBindable) {
        guard let postId = object?.postId, let postType = object?.type else { return }
        print(postId, postType)
        switch viewController {
        case is NewsfeedViewController:
            guard let sourceId = object?.sourceId else { return }
            (viewController as? NewsfeedViewController)?.presenter?.start(request: .unlike(postId: postId, sourceId: sourceId, type: postType))
        case is ProfileViewController:
            guard let sourceId = object?.id else { return }
            (viewController as? ProfileViewController)?.presenter?.start(request: .unlike(postId: postId, sourceId: sourceId, type: postType))
        default:
            break
        }
    }
    
    func openPhoto(for cell: NewsFeedCell, with url: String?) {
        
    }
    
    func openComments(for cell: NewsFeedCell) {
        
    }
    
    func share(for cell: NewsFeedCell) {
        
    }
}
