//
//  StoriesResponse.swift
//  VKExt
//
//  Created by programmist_NA on 13.07.2020.
//

import Foundation

struct HistoryResponse: Decodable {
    let count: Int?
    let items: [StoryItem]?
    let profiles: [ProfileHistory]?
    let groups: [GroupHistory]?
    let needUploadScreen: Bool?
}

// MARK: - Group
struct GroupHistory: Decodable, ProfileRepresenatable {
    // var pageType: RepresenatableType { return .group }
    var verified: Int?
    let id: Int
    let name: String
    let screenName: String?
    let isClosed: Int?
    let type: GroupType?
    let isAdmin, isMember, isAdvertiser: Int?
    let photo50, photo100, photo200: String?
    var photo: String { return photo100 ?? "" }
    var sex: Int? = 0
}

enum GroupType: String, Decodable {
    case group
    case page
}

// MARK: - Item
struct StoryItem: Decodable {
    let type: String?
    let stories: [ItemStory]?
    let promoData: PromoData?
    let grouped: [Grouped]?
}

// MARK: - Grouped
struct Grouped: Decodable {
    let type: String?
    let stories: [GroupedStory]?
}

// MARK: - GroupedStory
struct GroupedStory: Decodable {
    let id, ownerId: Int?
    let accessKey: String?
    let canComment, canReply, canSee: Int?
    let canLike: Bool?
    let canShare, canHide, date, expiresAt: Int?
    let parentStory: ParentStory?
    let parentStoryId, parentStoryOwnerId: Int?
    let replies: Replies?
    let isOneTime: Bool?
    let trackCode: String?
    let type: ParentStoryType?
    let clickableStickers: ClickableStickers?
    let video: PurpleVideo?
    let isRestricted, noSound, needMute, muteReply: Bool?
    let canAsk, canAskAnonymous: Int?
    let isOwnerPinned: Bool?
    let photo: Photo?
    let link: Link?
}

// MARK: - ClickableStickers
struct ClickableStickers: Decodable {
    let originalHeight, originalWidth: Int?
    let clickableStickers: [ClickableSticker]?
}

// MARK: - ClickableSticker
struct ClickableSticker: Decodable {
    let id: Int?
    let type: String?
    let clickableArea: [ClickableArea]?
    let ownerId, storyId, postOwnerId, postId: Int?
    let poll: Poll?
}

// MARK: - ClickableArea
struct ClickableArea: Decodable {
    let x, y: Int?
}

// MARK: - Poll
struct Poll: Decodable {
    let anonymous, multiple: Bool?
    let endDate: Int?
    let closed, isBoard, canEdit, canVote: Bool?
    let canReport, canShare: Bool?
    let created, id, ownerId: Int?
    let question: String?
    let votes: Int?
    let disableUnvote: Bool?
    let friends: [Friend]?
    let answers: [Answer]?
    let authorId: Int?
}

// MARK: - Answer
struct Answer: Decodable {
    let id: Int?
    let rate: Double?
    let text: String?
    let votes: Int?
}

// MARK: - Friend
struct Friend: Decodable {
    let id: Int?
}

// MARK: - Link
struct Link: Decodable {
    let text: String?
    let url: String?
}

// MARK: - ParentStory
struct ParentStory: Decodable {
    let id, ownerId: Int?
    let accessKey: String?
    let canComment, canReply, canSee: Int?
    let canLike: Bool?
    let canShare, canHide: Int?
    let date, expiresAt: Int
    let replies: Replies?
    let isOneTime: Bool?
    let trackCode: String?
    let type: ParentStoryType?
    let video: ParentStoryVideo?
    let isRestricted, noSound, needMute, muteReply: Bool?
    let canAsk, canAskAnonymous: Int?
    let isOwnerPinned, isExpired: Bool?
}

// MARK: - Replies
struct Replies: Decodable {
    let count, new: Int?
}

enum ParentStoryType: String, Decodable {
    case photo
    case video
}

// MARK: - ParentStoryVideo
struct ParentStoryVideo: Decodable {
    let accessKey: String?
    let canAdd, isPrivate, date: Int?
    let videoDescription: String?
    let duration: Int?
    let image, firstFrame: [Size]?
    let width, height, id, ownerId: Int?
    let title: String?
    let player: String?
    let type: ParentStoryType?
    let views: Int?
}

// MARK: - Photo
struct History: Decodable {
    let albumId, date, id, ownerId: Int?
    let hasTags: Bool?
    let sizes: [PhotoSize]?
    let text: String?
    let userId: Int?
}

// MARK: - PurpleVideo
struct PurpleVideo: Decodable {
    let accessKey: String?
    let canAdd, isPrivate, date: Int?
    let videoDescription: String?
    let duration: Int?
    let image, firstFrame: [Size]?
    let width, height, id, ownerId: Int?
    let title: String?
    let player: String?
    let type: ParentStoryType?
    let views: Int?
}

// MARK: - PromoData
struct PromoData: Decodable {
    let name: String?
    let photo50, photo100: String?
    let notAnimated: Bool?
}

// MARK: - ItemStory
struct ItemStory: Decodable {
    let id, ownerId: Int?
    let accessKey: String?
    let canComment, canReply, canSee: Int?
    let canLike: Bool?
    let canShare, canHide, date: Int?
    let expiresAt: Int?
    let photo: Photo?
    let replies: Replies?
    let isOneTime: Bool?
    let trackCode: String?
    let type: ParentStoryType?
    let clickableStickers: ClickableStickers?
    let isRestricted, noSound, needMute, muteReply: Bool?
    let canAsk, canAskAnonymous: Int?
    let isOwnerPinned: Bool?
    let link: Link?
    let video: FluffyVideo?
    let parentStory: ParentStory?
    let parentStoryId, parentStoryOwnerId: Int?
}

// MARK: - FluffyVideo
struct FluffyVideo: Decodable {
    let accessKey: String?
    let canAdd, isPrivate, date: Int?
    let videoDescription: String?
    let duration: Int?
    let image, firstFrame: [Size]?
    let width, height, id, ownerId: Int?
    let title: String?
    let player: String?
    let type: ParentStoryType?
    let views: Int?
}

// MARK: - Profile
struct ProfileHistory: Decodable, ProfileRepresenatable {
    // var pageType: RepresenatableType { return .profile }
    var verified: Int?
    let id: Int
    let firstName, lastName: String?
    let isClosed, canAccessClosed: Bool?
    var name: String { return firstName! + " " + lastName! }
    var photo: String { return "" }
    var sex: Int?
}
