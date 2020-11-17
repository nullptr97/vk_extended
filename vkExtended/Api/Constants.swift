//
//  Constants.swift
//  Api
//
//  Created by Ярослав Стрельников on 19.10.2020.
//

import Foundation
import UIKit

public struct Constants {
    public static let appId: String = "3140623"
    public static let clientSecret: String = "VeWdmVclDCtn6ihuP1nt"
    public static let currentUserId: Int = UserDefaults.standard.integer(forKey: "userId")
    public static let isCurrentUserBlocked: Bool = UserDefaults.standard.bool(forKey: "blockStatus")
    public static let verifyProfilesInt: [Int] = [565872157, 557526975, -196655673, 386246393, 93266796, 137471776, 109366233]
    public static let commandProfiles: [String] = ["565872157", "557526975", "386246393", "137471776", "109366233", "93266796"]
    public static let verifyProfilesNames: [String] = ["#extended_team", "#extended_updates"]
    public static let userFields: String = "counters,photo_id,verified,sex,bdate,city,country,home_town,has_photo,photo_50,photo_100,photo_200_orig,photo_200,photo_400_orig,photo_max,photo_max_orig,domain,has_mobile,contacts,site,education,universities,status,last_seen,followers_count,common_count,occupation,nickname,relatives,relation,personal,connections,exports,activities,interests,music,movies,tv,books,games,about,quotes,can_post,can_see_all_posts,can_see_audio,can_write_private_message,can_send_friend_request,is_favorite,is_hidden_from_feed,timezone,screen_name,maiden_name,crop_photo,is_friend,friend_status,career,military,blacklisted,blacklisted_by_me,can_be_invited_group,status_id,online_info"
    public static let groupFields: String = "activity,city,country,place,description,wiki_page,members_count,counters,start_date,finish_date,can_post,can_see_all_posts,activity,status,contacts,links,fixed_post,verified,site,can_create_topic"
    public static let pushSettings = """
    {"msg":["on"], "chat":["on"], "friend":["on"], "reply":["on"], "mention":["on"], "story_answered":["on"], "tag_photo":["on"], "birthday":["on"], "content_achievements":["on"], "app_request":["on"], "money":["on"], "comment_commented":["on"], "like":["on"], "vk_apps_open_url":["on"], "friend_accepted":["on"], "interest_post":["on"], "wall_publish":["on"], "sdk_open":["on"], "private_group_post":["on"], "group_invite":["on"], "story_reply":["on"], "podcasts":["on"], "comment":["on"], "wall_post":["on"], "repost":["on"], "missed_call":["on"], "friend_found":["on"], "call":["on"], "group_accepted":["on"], "chat_mention":["on"], "story_asked":["on"], "event_soon":["on"], "live":["on"], "reminder":["on"], "gift":["on"], "new_post":["on"], "associated_events":["on"]}
    """
    static let outMessageFlags: [Int] = [3, 7, 19, 23, 35, 39, 51, 55, 2105395]
    static let inMessageFlags: [Int] = [1, 5, 17, 21, 33, 37, 49, 53, 8227, 65178, 532481, 2629633, 532497]
    static let removeMessageFlags: [Int] = [128, 131072, 131200]
    
    static func verifyingProfile(from userId: Int) -> Bool {
        guard (self.verifyProfilesInt.filter { $0 == userId }.first != nil) else { return false }
        return true
    }
    
    static func verifyingChat(from chatName: String) -> Bool {
        guard (self.verifyProfilesNames.filter { $0 == chatName }.first != nil) else { return false }
        return true
    }
    
    // Other
    static let cardInsets = UIEdgeInsets(top: 3, left: 8, bottom: 3, right: 8)
    static let cardOffset = UIEdgeInsets(top: 3, left: 8, bottom: 3, right: 8)
    static let postLabelInsets = UIEdgeInsets(top: 10 + Constants.topViewHeight + 8, left: 12, bottom: 12, right: 12)
    static let postLabelRepostInsets = UIEdgeInsets(top: 10 + Constants.topViewHeight + Constants.topRepostViewHeight + 16, left: 12, bottom: 12, right: 12)
    static let postLabelFont = GoogleSansFont.regular(with: 15)
    static let topViewHeight: CGFloat = 48
    static let topRepostViewHeight: CGFloat = 40
    
    static let bottomViewHeight: CGFloat = 50
    
    static let bottomViewViewHeight: CGFloat = 44
    static let bottomViewViewWidth: CGFloat = 60
    static let bottomViewViewsIconSize: CGFloat = 22
    
    static let minifiedPostLimitLines: CGFloat = 8
    static let minifiedPostLines: CGFloat = 8
    
    static let moreTextButtonInsets = UIEdgeInsets(top: 2, left: 12, bottom: 0, right: 12)
    static let moreTextButtonSize = CGSize(width: 170, height: 30)
    /// Size of the avatar in the nav bar in small state.
    static let kNavBarAvatarSmallState: CGFloat = 32

    /// Size of the avatar in group topics.
    static let kAvatarSize: CGFloat = 32

    static let kProgressCircleSize: CGFloat = 40

    // Size of delivery marker (checkmarks etc)
    static let kDeliveryMarkerSize: CGFloat = 8
    // Horizontal space between delivery marker and the edge of the message bubble
    static let kDeliveryMarkerPadding: CGFloat = 0
    // Horizontal space between delivery marker and timestamp
    static let kTimestampPadding: CGFloat = 0
    // Approximate width of the timestamp
    static let kTimestampWidth: CGFloat = 50
    // Progress bar paddings.
    static let kProgressBarLeftPadding: CGFloat = 10
    static let kProgressBarRightPadding: CGFloat = 25

    // Color of "read" delivery marker.
    static let kDeliveryMarkerTint = UIColor(red: 19/255, green: 144/255, blue:255/255, alpha: 0.8)
    // Color of all other markers.
    static let kDeliveryMarkerColor = UIColor.gray.withAlphaComponent(0.7)

    // Light/dark gray color: outgoing messages
    static var kOutgoingBubbleColor: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                if UITraitCollection.userInterfaceStyle == .dark {
                    return .color(from: 0x454647)
                } else {
                    return .color(from: 0xCCE4FF)
                }
            }
        } else {
            return .color(from: 0xCCE4FF)
        }
    }
    static var kTextColor: UIColor {
        return .adaptableBlack
    }
    
    static var kRemovedTextColor: UIColor {
        return .adaptableRed
    }
    // Bright/dark green color
    static var kIncomingBubbleColor: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                if UITraitCollection.userInterfaceStyle == .dark {
                    return .color(from: 0x2C2D2E)
                } else {
                    return .color(from: 0xEBEDF0)
                }
            }
        } else {
            return .color(from: 0xEBEDF0)
        }
    }
    // Meta-messages, such as "Content deleted".
    static let kDeletedMessageBubbleColorLight = UIColor.color(from: 0xe3f2fd)
    static let kDeletedMessageBubbleColorDark = UIColor.color(from: 0x263238)
    static let kDeletedMessageTextColor = UIColor.gray

    static let kContentFont = UIFont.preferredFont(forTextStyle: .body)

    static let kSenderNameFont = UIFont.preferredFont(forTextStyle: .caption2)
    static let kTimestampFont = GoogleSansFont.regular(with: 10)
    static let kSenderNameLabelHeight: CGFloat = 0
    static let kNewDateFont = GoogleSansFont.medium(with: 13)
    static let kNewDateLabelHeight: CGFloat = 48
    static let kNewMessagesLabelHeight: CGFloat = 48
    // Vertical spacing between messages from the same user
    static let kVerticalCellSpacing: CGFloat = 4
    // Additional vertical spacing between messages from different users in P2P topics.
    static let kAdditionalP2PVerticalCellSpacing: CGFloat = 4
    static let kMinimumCellWidth: CGFloat = 36
    static let kMinimumCellHeight: CGFloat = 36
    // This is the space between the other side of the message and the edge of screen.
    // I.e. for incoming messages the space between the message and the *right* edge, for
    // outfoing between the message and the left edge.
    static let kFarSideHorizontalSpacing: CGFloat = 56

    // Insets around collection view, i.e. main view padding
    static let kCollectionViewInset = UIEdgeInsets(top: 52, left: 4, bottom: 8, right: 2)

    // Insets for the message bubble relative to collectionView: bubble should not touch the sides of the screen.
    static let kIncomingContainerPadding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: percent(with: UIScreen.main.bounds.width, from: 8))
    static let kOutgoingContainerPadding = UIEdgeInsets(top: 0, left: percent(with: UIScreen.main.bounds.width, from: 20), bottom: 0, right: 0)

    // Insets around content inside the message bubble.
    static let kIncomingMessageContentInset = UIEdgeInsets(top: 7, left: 12, bottom: 7, right: 12)
    static let kOutgoingMessageContentInset = UIEdgeInsets(top: 7, left: 12, bottom: 7, right: 12)
    static let kDeletedMessageContentInset = UIEdgeInsets(top: 7, left: 12, bottom: 7, right: 12)

    // Carve out for timestamp and delivery marker in the bottom-right corner.
    static let kIncomingMetadataCarveout = ""
    static let kOutgoingMetadataCarveout = ""
    static let kTimeStampCarveout = "          "
}
func percent(with value: CGFloat, from percent: CGFloat) -> CGFloat {
    let val = value * percent
    return val / 100.0
}
