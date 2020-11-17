//
//  AttachmentsService.swift
//  VKExt
//
//  Created by Ярослав Стрельников on 31.08.2020.
//

import Foundation
import UIKit

class AttachmentsService: NSObject {
    static let instance: AttachmentsService = AttachmentsService()
    
    func formattedCounter(_ counter: Int?) -> String? {
        guard let counter = counter, counter > 0 else { return nil }
        var counterString = String(counter)
        if 4...6 ~= counterString.count {
            counterString = String(counterString.dropLast(3)) + "K"
        } else if counterString.count > 6 {
            counterString = String(counterString.dropLast(6)) + "M"
        }
        return counterString
    }
    
    func profile(for sourseId: Int, profiles: [Profile] = [], groups: [Group] = []) -> ProfileRepresenatable {
        
        let profilesOrGroups: [ProfileRepresenatable]
        profilesOrGroups = sourseId >= 0 ? profiles : groups
        let normalSourseId = sourseId >= 0 ? sourseId : -sourseId
        let profileRepresenatable = profilesOrGroups.first { (myProfileRepresenatable) -> Bool in
            myProfileRepresenatable.id == normalSourseId
        }
        return profileRepresenatable!
    }
    
    func attachments(feedItem: FeedItem) -> [FeedViewModel.FeedCellPhotoAttachment] {
        guard let attachments = feedItem.attachments else { return [] }
        
        return attachments.compactMap({ (attachment) -> FeedViewModel.FeedCellPhotoAttachment? in
            if let photo = attachment.photo {
                return FeedViewModel.FeedCellPhotoAttachment.init(photoUrlString: photo.srcBIG,
                                                                  photoMaxUrl: photo.srcMax,
                                                                  width: photo.width,
                                                                  height: photo.height)
            } else if let doc = attachment.doc {
                return FeedViewModel.FeedCellPhotoAttachment.init(gifUrl: doc.url,
                                                                  photoUrlString: doc.preview?.photo?.srcBIG ?? "",
                                                                  photoMaxUrl: doc.preview?.photo?.srcMax ?? "",
                                                                  width: doc.preview?.photo?.width ?? 0,
                                                                  height: doc.preview?.photo?.height ?? 0)
            } else {
                return nil
            }
        })
    }
    
    func attachments(wallItem: WallItem) -> [FeedViewModel.FeedCellPhotoAttachment] {
        guard let attachments = wallItem.attachments else { return [] }
        
        return attachments.compactMap({ (attachment) -> FeedViewModel.FeedCellPhotoAttachment? in
            if let photo = attachment.photo {
                return FeedViewModel.FeedCellPhotoAttachment.init(photoUrlString: photo.srcBIG,
                                                                  photoMaxUrl: photo.srcMax,
                                                                  width: photo.width,
                                                                  height: photo.height)
            } else if let doc = attachment.doc {
                return FeedViewModel.FeedCellPhotoAttachment.init(gifUrl: doc.url,
                                                                  photoUrlString: doc.preview?.photo?.srcBIG ?? "",
                                                                  photoMaxUrl: doc.preview?.photo?.srcMax ?? "",
                                                                  width: doc.preview?.photo?.width ?? 0,
                                                                  height: doc.preview?.photo?.height ?? 0)
            } else {
                return nil
            }
        })
    }
    
    func attachments(repostItem: RepostItem) -> [FeedViewModel.FeedCellPhotoAttachment] {
        guard let attachments = repostItem.attachments else { return [] }
        
        return attachments.compactMap({ (attachment) -> FeedViewModel.FeedCellPhotoAttachment? in
            if let photo = attachment.photo {
                return FeedViewModel.FeedCellPhotoAttachment.init(photoUrlString: photo.srcBIG,
                                                                  photoMaxUrl: photo.srcMax,
                                                                  width: photo.width,
                                                                  height: photo.height)
            } else if let doc = attachment.doc {
                return FeedViewModel.FeedCellPhotoAttachment.init(gifUrl: doc.url,
                                                                  photoUrlString: doc.preview?.photo?.srcBIG ?? "",
                                                                  photoMaxUrl: doc.preview?.photo?.srcMax ?? "",
                                                                  width: doc.preview?.photo?.width ?? 0,
                                                                  height: doc.preview?.photo?.height ?? 0)
            } else {
                return nil
            }
        })
    }
//
//    func linkAttachments(feedItem: FeedItem) -> [FeedViewModel.FeedCellLinkAttachment] {
//        guard let attachments = feedItem.attachments else { return [] }
//
//        return attachments.compactMap({ (attachment) -> FeedViewModel.FeedCellLinkAttachment? in
//            if let link = attachment.link {
//                return FeedViewModel.FeedCellLinkAttachment.init(photoUrlString: link.photo?.srcBIG, photoMaxUrl: link.photo?.srcMax, title: link.title, caption: link.caption, url: URL(string: link.url!), width: link.photo?.width ?? 0, height: link.photo?.height ?? 0)
//            } else {
//                return nil
//            }
//        })
//    }
//
//    func linkAttachments(wallItem: WallItem) -> [FeedViewModel.FeedCellLinkAttachment] {
//        guard let attachments = wallItem.attachments else { return [] }
//
//        return attachments.compactMap({ (attachment) -> FeedViewModel.FeedCellLinkAttachment? in
//            if let link = attachment.link {
//                return FeedViewModel.FeedCellLinkAttachment.init(photoUrlString: link.photo?.srcBIG, photoMaxUrl: link.photo?.srcMax, title: link.title, caption: link.caption, url: URL(string: link.url!), width: link.photo?.width ?? 0, height: link.photo?.height ?? 0)
//            } else {
//                return nil
//            }
//        })
//    }
//
//    func linkAttachments(repostItem: RepostItem) -> [FeedViewModel.FeedCellLinkAttachment] {
//        guard let attachments = repostItem.attachments else { return [] }
//
//        return attachments.compactMap({ (attachment) -> FeedViewModel.FeedCellLinkAttachment? in
//            if let link = attachment.link {
//                return FeedViewModel.FeedCellLinkAttachment.init(photoUrlString: link.photo?.srcBIG, photoMaxUrl: link.photo?.srcMax, title: link.title, caption: link.caption, url: URL(string: link.url!), width: link.photo?.width ?? 0, height: link.photo?.height ?? 0)
//            } else {
//                return nil
//            }
//        })
//    }
}
