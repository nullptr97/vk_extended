//
//  LikesViewModel.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 03.12.2020.
//

import Foundation

enum LikesModel {
    struct Request {
        enum RequestType {
            case getLikes(postId: Int, sourceId: Int, type: String)
            case getFriendsLikes(postId: Int, sourceId: Int, type: String, friendsOnly: Bool)
        }
    }
    struct Response {
        enum ResponseType {
            case presentLikes(response: FriendResponse)
            case presentFriendsLikes(response: FriendResponse)
        }
    }
    struct ViewModel {
        enum ViewModelData {
            case displayLikes(profileViewModel: FriendViewModel)
            case displayFriendsLikes(profileViewModel: FriendViewModel)
        }
    }
}
