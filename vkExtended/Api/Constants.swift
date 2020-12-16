//
//  Constants.swift
//  Api
//
//  Created by Ярослав Стрельников on 19.10.2020.
//

import Foundation
import UIKit

var currentUserId: Int = UserDefaults.standard.integer(forKey: "userId")

public struct Constants {
    public static let appId: String = "2274003"
    public static let clientSecret: String = "hHbZxrka2uZ6jB1inYsH"
    public static let userAgent: String = "VKAndroidApp/5.23-2978 (Android 4.4.2; SDK 19; x86; unknown Android SDK built for x86; en; 320x240)"
    public static let isCurrentUserBlocked: Bool = UserDefaults.standard.bool(forKey: "blockStatus")
    public static let verifyProfilesInt: [Int] = [565872157, 557526975, -196655673, 386246393, 93266796, 137471776, 109366233]
    public static let commandProfiles: [String] = ["565872157", "557526975", "386246393", "137471776", "109366233", "93266796"]
    public static let verifyProfilesNames: [String] = ["#extended_team", "#extended_updates"]
    public static let userFields: String = "image_status,emoji_status,first_name_nom,first_name_gen,first_name_dat,first_name_acc,first_name_ins, first_name_abl,last_name_nom,last_name_gen,last_name_dat,last_name_acc,last_name_ins,last_name_abl,counters,photo_id,verified,sex,bdate,city,country,home_town,has_photo,photo_50,photo_100,photo_200_orig,photo_200,photo_400_orig,photo_max,photo_max_orig,domain,has_mobile,contacts,site,education,universities,status,last_seen,followers_count,common_count,occupation,nickname,relatives,relation,personal,connections,exports,activities,interests,music,movies,tv,books,games,about,quotes,can_post,can_see_all_posts,can_see_audio,can_write_private_message,can_send_friend_request,is_favorite,is_hidden_from_feed,timezone,screen_name,maiden_name,crop_photo,is_friend,friend_status,career,military,blacklisted,blacklisted_by_me,can_be_invited_group,status_id,online_info"
    public static let groupFields: String = "activity,city,country,place,description,wiki_page,members_count,counters,start_date,finish_date,can_post,can_see_all_posts,activity,status,contacts,links,fixed_post,verified,site,can_create_topic"
    public static let pushSettings = """
    {"msg":["on"], "chat":["on"], "friend":["on"], "reply":["on"], "mention":["on"], "story_answered":["on"], "tag_photo":["on"], "birthday":["on"], "content_achievements":["on"], "app_request":["on"], "money":["on"], "comment_commented":["on"], "like":["on"], "vk_apps_open_url":["on"], "friend_accepted":["on"], "interest_post":["on"], "wall_publish":["on"], "sdk_open":["on"], "private_group_post":["on"], "group_invite":["on"], "story_reply":["on"], "podcasts":["on"], "comment":["on"], "wall_post":["on"], "repost":["on"], "missed_call":["on"], "friend_found":["on"], "call":["on"], "group_accepted":["on"], "chat_mention":["on"], "story_asked":["on"], "event_soon":["on"], "live":["on"], "reminder":["on"], "gift":["on"], "new_post":["on"], "associated_events":["on"]}
    """
    static let outMessageFlags: [Int] = [3, 7, 19, 23, 35, 39, 51, 55, 2105395]
    static let inMessageFlags: [Int] = [1, 5, 17, 21, 33, 37, 49, 53, 8227, 65178, 532481, 2629633, 532497]
    static let removeMessageFlags: [Int] = [128, 131072, 131200]
    
    static func updateCurrentUserId() {
        currentUserId = UserDefaults.standard.integer(forKey: "userId")
    }
    
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
    
    static let minifiedPostLimitLines: CGFloat = 7
    static let minifiedPostLines: CGFloat = 7
    
    static let moreTextButtonInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    static let moreTextButtonSize = CGSize(width: screenWidth - 32, height: 24)
}
func percent(with value: CGFloat, from percent: CGFloat) -> CGFloat {
    let val = value * percent
    return val / 100.0
}
