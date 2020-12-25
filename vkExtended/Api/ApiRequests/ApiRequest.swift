//
//  ApiRequest.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 29.11.2020.
//

import Foundation
import SwiftyJSON
import Alamofire
import PromiseKit
import AwesomeCache

let apiUrl = "https://api.vk.com/method/"
let userAgent = ["User-Agent" : Constants.userAgent]
let userAgentMac = ["User-Agent" : "Mozilla/5.0 (Macintosh; Intel Mac OS X 11_0_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36"]

struct Api {
    static func getParameters(method: String, _ parameters: inout Alamofire.Parameters, _ token: String, v: Double = 5.126) -> Alamofire.Parameters {
        let sortedKeys = Array(parameters.keys).sorted(by: <)
        
        var md5String = "/method/\(method)?"
        for key in sortedKeys {
            md5String = md5String + key + "=\(parameters[key] ?? "")&"
        }
        if md5String.last! == "&" {
            md5String.remove(at: md5String.index(before: md5String.endIndex))
        }
        md5String = md5String + Constants.clientSecret
        parameters["lang"] = "ru"
        parameters["v"] = v
        parameters["access_token"] = token
        parameters["sig"] = MD5.MD5(md5String)
        
        return parameters
    }
    
    struct Account {
        static func ban(ownerId: Int) throws -> Promise<Int> {
            guard let token = VK.sessions.default.accessToken?.token else { throw VKError.noAccessToken("Токен отсутствует, повторите авторизацию") }
            var parameters: Alamofire.Parameters = [Parameter.ownerId.rawValue : ownerId]
            
            return firstly {
                Alamofire.request(apiUrl + "account.ban", method: .get, parameters: Api.getParameters(method: "account.ban", &parameters, token), encoding: URLEncoding.default, headers: userAgent).responseData()
            }.compactMap {
                if let apiError = ApiError($0.data.json(has: false)) {
                    throw VKError.api(apiError)
                } else {
                    return $0.data.json().intValue
                }
            }
        }
    }
    
    struct Ads {}

    struct AppWidget {}

    struct Apps {}

    struct Audio {
        static func get(ownerId: Int = currentUserId, count: Int = 200) throws -> Promise<[AudioViewModel]> {
            guard let token = VK.sessions.default.accessToken?.token else { throw VKError.noAccessToken("Токен отсутствует, повторите авторизацию") }
            var parameters: Alamofire.Parameters = [Parameter.ownerId.rawValue : ownerId]
            let cache = try! Cache<NSData>(name: "audioCache")
            return firstly {
                Alamofire.request(apiUrl + "audio.get", method: .get, parameters: Api.getParameters(method: "audio.get", &parameters, token, v: 5.89), encoding: URLEncoding.default, headers: userAgent).responseData()
            }.compactMap {
                if let apiError = ApiError($0.data.json(has: false)) {
                    print("audio.get 👎🏻")
                    throw VKError.api(apiError)
                } else {
                    print("audio.get 👍🏻")
                    
                    if cache["audio_from_id\(ownerId)"] != nil {
                        cache.removeObjectForKey(key: "audio_from_id\(ownerId)")
                    }
                    cache["audio_from_id\(ownerId)"] = $0.data as NSData
                    
                    return $0.data.json()["items"].arrayValue.compactMap { AudioViewModel(audio: $0) }
                }
            }
        }
    }
    
    struct Board {}

    struct Database {}

    struct Docs {}
    
    struct Execute {
        static func groupsGet(userId: Int = currentUserId, count: Int = 20, offset: Int = 0) throws -> Promise<GroupResponse> {
            guard let token = VK.sessions.default.accessToken?.token else { throw VKError.noAccessToken("Токен отсутствует, повторите авторизацию") }
            var parameters: Alamofire.Parameters = [
                Parameter.fields.rawValue: Constants.groupFields,
                Parameter.count.rawValue: 50,
                Parameter.offset.rawValue: offset,
                Parameter.userId.rawValue: userId
            ]
            
            return firstly {
                Alamofire.request(apiUrl + "execute.groupsGet", method: .post, parameters: Api.getParameters(method: "execute.groupsGet", &parameters, token), encoding: URLEncoding.default, headers: userAgent).responseData()
            }.compactMap { response in
                if let apiError = ApiError(response.data.json()) {
                    print("execute.groupsGet 👎🏻")
                    throw VKError.api(apiError)
                } else {
                    print("execute.groupsGet 👍🏻")
                    return GroupResponse(from: response.data.json())
                }
            }
        }
        
        static func getProfilePage(code: String) throws -> Promise<(ProfileResponse, PhotoResponse?, FriendResponse?)> {
            guard let token = VK.sessions.default.accessToken?.token else { throw VKError.noAccessToken("Токен отсутствует, повторите авторизацию") }
            var parameters: Alamofire.Parameters = [Parameter.code.rawValue : code]
            let cache = try! Cache<NSData>(name: "profileCache")
            return firstly {
                Alamofire.request(apiUrl + "execute", method: .post, parameters: Api.getParameters(method: "execute", &parameters, token), encoding: URLEncoding.default, headers: userAgent).responseData()
            }.compactMap {
                if let apiError = ApiError($0.data.json(has: false)) {
                    print("execute.getProfilePage 👎🏻")
                    throw VKError.api(apiError)
                } else {
                    print("execute.getProfilePage 👍🏻")
                    guard let profile = $0.data.json()["profile"].arrayValue.first else { throw VKError.emptyJSON("Объект пуст") }
                    
                    if cache["profile_from_id\(profile["id"].intValue)"] != nil {
                        cache.removeObjectForKey(key: "profile_from_id\(profile["id"].intValue)")
                    }
                    cache["profile_from_id\(profile["id"].intValue)"] = $0.data as NSData
                    
                    return (ProfileResponse(from: profile), PhotoResponse(from: $0.data.json()["photos"]), FriendResponse(from: $0.data.json()["friends"]))
                }
            }
        }
        
        static func getNewsfeedSmart(count: Int = 200) throws -> Promise<FeedResponse> {
            guard let token = VK.sessions.default.accessToken?.token else { throw VKError.noAccessToken("Токен отсутствует, повторите авторизацию") }
            var parameters: Alamofire.Parameters = [
                Parameter.fields.rawValue: Constants.userFields,
                Parameter.filters.rawValue: "post, photo_tag, photo",
                Parameter.count.rawValue: 40
            ]
            
            return firstly {
                Alamofire.request(apiUrl + "execute.getNewsfeedSmart", method: .post, parameters: Api.getParameters(method: "execute.getNewsfeedSmart", &parameters, token), encoding: URLEncoding.default, headers: userAgent).responseData()
            }.compactMap { response in
                if let apiError = ApiError(response.data.json()) {
                    print("execute.getNewsfeedSmart 👎🏻")
                    throw VKError.api(apiError)
                } else {
                    print("execute.getNewsfeedSmart 👍🏻")
                    return FeedResponse(from: response.data.json())
                }
            }
        }
        
        static func profileFriendsBlock(userId: Int = currentUserId, count: Int = 20, offset: Int = 0) throws -> Promise<FriendResponse> {
            guard let token = VK.sessions.default.accessToken?.token else { throw VKError.noAccessToken("Токен отсутствует, повторите авторизацию") }
            var parameters: Alamofire.Parameters = [
                Parameter.count.rawValue: count,
                Parameter.userId.rawValue: userId,
                Parameter.offset.rawValue: offset
            ]
            return firstly {
                Alamofire.request(apiUrl + "execute.profileFriendsBlock", method: .get, parameters: Api.getParameters(method: "execute.profileFriendsBlock", &parameters, token), encoding: URLEncoding.default, headers: userAgent).responseData()
            }.compactMap {
                if let apiError = ApiError($0.data.json(has: false)) {
                    print("execute.profileFriendsBlock 👎🏻")
                    throw VKError.api(apiError)
                } else {
                    print("execute.profileFriendsBlock 👍🏻")
                    return FriendResponse(from: $0.data.json())
                }
            }
        }
        
        static func wallGetWrapNew(ownerId: Int = currentUserId, offset: Int = 0) throws -> Promise<WallResponse> {
            guard let token = VK.sessions.default.accessToken?.token else { throw VKError.noAccessToken("Токен отсутствует, повторите авторизацию") }
            var parameters: Alamofire.Parameters = [
                Parameter.ownerId.rawValue: ownerId,
                Parameter.fields.rawValue: Constants.userFields,
                Parameter.filter.rawValue: "all",
                Parameter.extended.rawValue: 1,
                Parameter.offset.rawValue: offset,
                Parameter.count.rawValue: 20
            ]
            let cache = try! Cache<NSData>(name: "wallCache")
            return firstly {
                Alamofire.request(apiUrl + "execute.wallGetWrapNew", method: .post, parameters: Api.getParameters(method: "execute.wallGetWrapNew", &parameters, token), encoding: URLEncoding.default, headers: userAgent).responseData()
            }.compactMap { response in
                if let apiError = ApiError(response.data.json()) {
                    print("execute.wallGetWrapNew 👎🏻")
                    throw VKError.api(apiError)
                } else {
                    print("execute.wallGetWrapNew 👍🏻")
                    
                    if cache["wall_from_id\(ownerId)"] != nil {
                        cache.removeObjectForKey(key: "wall_from_id\(ownerId)")
                    }
                    cache["wall_from_id\(ownerId)"] = response.data as NSData

                    return WallResponse(from: response.data.json())
                }
            }
        }
    }

    struct Fave {}

    struct Friends {
        static func get(userId: Int = currentUserId, count: Int = 20, order: String = "hints", offset:  Int = 0) throws -> Promise<FriendResponse> {
            guard let token = VK.sessions.default.accessToken?.token else { throw VKError.noAccessToken("Токен отсутствует, повторите авторизацию") }
            var parameters: Alamofire.Parameters = [
                Parameter.fields.rawValue: Constants.userFields,
                Parameter.order.rawValue: order,
                Parameter.userId.rawValue: userId,
                Parameter.count.rawValue: count,
                Parameter.offset.rawValue: offset
            ]
            let cache = try! Cache<NSData>(name: "friendsCache")
            return firstly {
                Alamofire.request(apiUrl + "friends.get", method: .post, parameters: Api.getParameters(method: "friends.get", &parameters, token), encoding: URLEncoding.default, headers: userAgent).responseData()
            }.compactMap {
                if let apiError = ApiError($0.data.json(has: false)) {
                    print("friends.get 👎🏻")
                    throw VKError.api(apiError)
                } else {
                    print("friends.get 👍🏻")
                    
                    if cache["friends_from_id\(userId)"] != nil {
                        cache.removeObjectForKey(key: "friends_from_id\(userId)")
                    }
                    cache["friends_from_id\(userId)"] = $0.data as NSData
                    return FriendResponse(from: $0.data.json())
                }
            }
        }
        
        static func getSuggestions(count: Int = 20) throws -> Promise<FriendResponse> {
            guard let token = VK.sessions.default.accessToken?.token else { throw VKError.noAccessToken("Токен отсутствует, повторите авторизацию") }
            var parameters: Alamofire.Parameters = [
                Parameter.fields.rawValue: Constants.userFields,
                Parameter.count.rawValue: count
            ]
            
            return firstly {
                Alamofire.request(apiUrl + "friends.getSuggestions", method: .get, parameters: Api.getParameters(method: "friends.getSuggestions", &parameters, token), encoding: URLEncoding.default, headers: userAgent).responseData()
            }.compactMap {
                if let apiError = ApiError($0.data.json(has: false)) {
                    print("friends.getSuggestions 👎🏻")
                    throw VKError.api(apiError)
                } else {
                    print("friends.getSuggestions 👍🏻")
                    return FriendResponse(from: $0.data.json())
                }
            }
        }
    }
    
    struct Gifts {}

    struct Groups {}

    struct Leads {}
    
    struct Likes {
        static func add(postId: Int, sourceId: Int, type: String) throws -> Promise<Int> {
            guard let token = VK.sessions.default.accessToken?.token else { throw VKError.noAccessToken("Токен отсутствует, повторите авторизацию") }
            var parameters: Alamofire.Parameters = [
                Parameter.itemId.rawValue: postId,
                Parameter.ownerId.rawValue: sourceId,
                Parameter.type.rawValue: type
            ]
            
            return firstly {
                Alamofire.request(apiUrl + "likes.add", method: .post, parameters: Api.getParameters(method: "likes.add", &parameters, token), encoding: URLEncoding.default, headers: userAgent).responseData()
            }.compactMap {
                if let apiError = ApiError($0.data.json(has: false)) {
                    print("likes.add 👎🏻")
                    throw VKError.api(apiError)
                } else {
                    print("likes.add 👍🏻")
                    return $0.data.json()["likes"].intValue
                }
            }
        }
        
        static func delete(postId: Int, sourceId: Int, type: String) throws -> Promise<Int> {
            guard let token = VK.sessions.default.accessToken?.token else { throw VKError.noAccessToken("Токен отсутствует, повторите авторизацию") }
            var parameters: Alamofire.Parameters = [
                Parameter.itemId.rawValue: postId,
                Parameter.ownerId.rawValue: sourceId,
                Parameter.type.rawValue: type
            ]
            
            return firstly {
                Alamofire.request(apiUrl + "likes.delete", method: .post, parameters: Api.getParameters(method: "likes.delete", &parameters, token), encoding: URLEncoding.default, headers: userAgent).responseData()
            }.compactMap {
                if let apiError = ApiError($0.data.json(has: false)) {
                    print("likes.delete 👎🏻")
                    throw VKError.api(apiError)
                } else {
                    print("likes.delete 👍🏻")
                    return $0.data.json()["likes"].intValue
                }
            }
        }
        
        static func getList(offset: Int = 0, count: Int = 100, postId: Int, sourceId: Int, type: String, friendsOnly: Bool = false, extended: Int = 1) throws -> Promise<FriendResponse> {
            guard let token = VK.sessions.default.accessToken?.token else { throw VKError.noAccessToken("Токен отсутствует, повторите авторизацию") }
            var parameters: Alamofire.Parameters = [
                Parameter.offset.rawValue: offset,
                Parameter.count.rawValue: count,
                Parameter.extended.rawValue: extended,
                Parameter.itemId.rawValue: postId,
                Parameter.ownerId.rawValue: sourceId,
                Parameter.type.rawValue: type,
                Parameter.friendsOnly.rawValue: friendsOnly,
                Parameter.fields.rawValue: Constants.userFields
            ]
            
            return firstly {
                Alamofire.request(apiUrl + "likes.getList", method: .post, parameters: Api.getParameters(method: "likes.delete", &parameters, token), encoding: URLEncoding.default, headers: userAgent).responseData()
            }.compactMap {
                if let apiError = ApiError($0.data.json(has: false)) {
                    print("likes.getList 👎🏻")
                    throw VKError.api(apiError)
                } else {
                    print("likes.getList 👍🏻")
                    return FriendResponse(from: $0.data.json())
                }
            }
        }
    }
    
    struct Messages {
        static func getConversations(offset: Int = 0, count: Int = 50, filter: String = "all", extended: Int = 1, fields: String = Constants.userFields) throws -> Promise<JSON> {
            guard let token = VK.sessions.default.accessToken?.token else { throw VKError.noAccessToken("Токен отсутствует, повторите авторизацию") }
            var parameters: Alamofire.Parameters = [
                Parameter.offset.rawValue: offset,
                Parameter.count.rawValue: count,
                Parameter.filter.rawValue: filter,
                Parameter.extended.rawValue: extended,
                Parameter.fields.rawValue: fields
            ]
            
            return firstly {
                Alamofire.request(apiUrl + "messages.getConversations", method: .post, parameters: Api.getParameters(method: "messages.getConversations", &parameters, token), encoding: URLEncoding.default, headers: userAgent).responseData()
            }.compactMap { response in
                if let apiError = ApiError(response.data.json()) {
                    print("messages.getConversations 👎🏻")
                    throw VKError.api(apiError)
                } else {
                    print("messages.getConversations 👍🏻")
                    return response.data.json()
                }
            }
        }
    }
    
    struct Newsfeed {
        static func get(startFrom: String = "", sourceIds: String = "") throws -> Promise<FeedResponse> {
            guard let token = VK.sessions.default.accessToken?.token else { throw VKError.noAccessToken("Токен отсутствует, повторите авторизацию") }
            var parameters: Alamofire.Parameters = [
                Parameter.fields.rawValue: Constants.userFields,
                Parameter.filters.rawValue: "post, photo_tag, photo",
                Parameter.count.rawValue: 40
            ]
            if !sourceIds.isEmpty {
                parameters["source_ids"] = sourceIds
            }
            if !startFrom.isEmpty {
                parameters["start_from"] = startFrom
            }
            
            return firstly {
                Alamofire.request(apiUrl + "newsfeed.get", method: .post, parameters: Api.getParameters(method: "newsfeed.get", &parameters, token), encoding: URLEncoding.default, headers: userAgent).responseData()
            }.compactMap { response in
                if let apiError = ApiError(response.data.json()) {
                    print("newsfeed.get 👎🏻")
                    throw VKError.api(apiError)
                } else {
                    print("newsfeed.get 👍🏻")
                    return FeedResponse(from: response.data.json())
                }
            }
        }
        
        static func getPostTopics() throws -> Promise<[(Int, String)]> {
            guard let token = VK.sessions.default.accessToken?.token else { throw VKError.noAccessToken("Токен отсутствует, повторите авторизацию") }
            var parameters: Alamofire.Parameters = [:]
            
            return firstly {
                Alamofire.request(apiUrl + "newsfeed.getPostTopics", method: .post, parameters: Api.getParameters(method: "newsfeed.getPostTopics", &parameters, token), encoding: URLEncoding.default, headers: userAgent).responseData()
            }.compactMap { response in
                if let apiError = ApiError(response.data.json()) {
                    print("newsfeed.getPostTopics 👎🏻")
                    throw VKError.api(apiError)
                } else {
                    print("newsfeed.getPostTopics 👍🏻")
                    return response.data.json().arrayValue.compactMap { ($0["id"].intValue, $0["name"].stringValue) }
                }
            }
        }
        
        static func getRecommended() throws -> Promise<FeedResponse> {
            guard let token = VK.sessions.default.accessToken?.token else { throw VKError.noAccessToken("Токен отсутствует, повторите авторизацию") }
            var parameters: Alamofire.Parameters = [
                Parameter.fields.rawValue: Constants.userFields,
                Parameter.count.rawValue: 40
            ]
            
            return firstly {
                Alamofire.request(apiUrl + "newsfeed.getRecommended", method: .post, parameters: Api.getParameters(method: "newsfeed.getRecommended", &parameters, token), encoding: URLEncoding.default, headers: userAgent).responseData()
            }.compactMap { response in
                if let apiError = ApiError(response.data.json()) {
                    print("newsfeed.getRecommended 👎🏻")
                    throw VKError.api(apiError)
                } else {
                    print("newsfeed.getRecommended 👍🏻")
                    return FeedResponse(from: response.data.json())
                }
            }
        }
        
        static func getUserTopicSources(topicId: Int) throws -> Promise<[Int]> {
            guard let token = VK.sessions.default.accessToken?.token else { throw VKError.noAccessToken("Токен отсутствует, повторите авторизацию") }
            var parameters: Alamofire.Parameters = [Parameter.topicId.rawValue: topicId]
            
            return firstly {
                Alamofire.request(apiUrl + "newsfeed.getUserTopicSources", method: .post, parameters: Api.getParameters(method: "newsfeed.getUserTopicSources", &parameters, token), encoding: URLEncoding.default, headers: userAgent).responseData()
            }.compactMap { response in
                if let apiError = ApiError(response.data.json()) {
                    print("newsfeed.getUserTopicSources 👎🏻")
                    throw VKError.api(apiError)
                } else {
                    print("newsfeed.getUserTopicSources 👍🏻")
                    return response.data.json()["items"].arrayValue.compactMap { $0["id"].intValue }
                }
            }
        }
    }
    
    struct Status {
        static func getImagePopup(userId: Int = currentUserId) throws -> Promise<ImagePopup> {
            guard let token = VK.sessions.default.accessToken?.token else { throw VKError.noAccessToken("Токен отсутствует, повторите авторизацию") }
            var parameters: Alamofire.Parameters = [Parameter.userId.rawValue: userId]
            
            return firstly {
                Alamofire.request(apiUrl + "status.getImagePopup", method: .post, parameters: Api.getParameters(method: "status.getImagePopup", &parameters, token), encoding: URLEncoding.default, headers: userAgent).responseData()
            }.compactMap { response in
                if let apiError = ApiError(response.data.json()) {
                    print("status.getImagePopup 👎🏻")
                    throw VKError.api(apiError)
                } else {
                    print("status.getImagePopup 👍🏻")
                    return ImagePopup(imagePopup: response.data.json())
                }
            }
        }
    }
    
    struct SuperApp {
        static func get(lat: Double? = nil, lon: Double? = nil) throws -> Promise<SuperAppServices> {
            guard let token = VK.sessions.default.accessToken?.token else { throw VKError.noAccessToken("Токен отсутствует, повторите авторизацию") }
            var parameters: Alamofire.Parameters = ["local_time": Date().iso8601String]
            if let lat = lat, let lon = lon {
                parameters["latitude"] = lat
                parameters["longitude"] = lon
            }
            let cache = try! Cache<NSData>(name: "superAppCache")
            return firstly {
                Alamofire.request(apiUrl + "superApp.get", method: .post, parameters: Api.getParameters(method: "superApp.get", &parameters, token), encoding: URLEncoding.default, headers: userAgent).responseData()
            }.compactMap { response in
                if let apiError = ApiError(response.data.json()) {
                    print("superApp.get 👎🏻")
                    throw VKError.api(apiError)
                } else {
                    print("superApp.get 👍🏻")
                    if cache["superApp"] != nil {
                        cache.removeObjectForKey(key: "superApp")
                    }
                    cache["superApp"] = response.data as NSData
                    return SuperAppServices(from: response.data.json())
                }
            }
        }
    }
    
    struct Wall {
        static func get(ownerId: Int = currentUserId, offset: Int = 0) throws -> Promise<WallResponse> {
            guard let token = VK.sessions.default.accessToken?.token else { throw VKError.noAccessToken("Токен отсутствует, повторите авторизацию") }
            var parameters: Alamofire.Parameters = [
                Parameter.ownerId.rawValue: ownerId,
                Parameter.fields.rawValue: Constants.userFields,
                Parameter.filter.rawValue: "all",
                Parameter.extended.rawValue: 1,
                Parameter.offset.rawValue: offset,
                Parameter.count.rawValue: 20
            ]
            let cache = try! Cache<NSData>(name: "wallCache")
            return firstly {
                Alamofire.request(apiUrl + "wall.get", method: .post, parameters: Api.getParameters(method: "wall.get", &parameters, token), encoding: URLEncoding.default, headers: userAgent).responseData()
            }.compactMap { response in
                if let apiError = ApiError(response.data.json()) {
                    print("wall.get 👎🏻")
                    throw VKError.api(apiError)
                } else {
                    print("wall.get 👍🏻")
                    
                    if cache["wall_from_id\(ownerId)"] != nil {
                        cache.removeObjectForKey(key: "wall_from_id\(ownerId)")
                    }
                    cache["wall_from_id\(ownerId)"] = response.data as NSData

                    return WallResponse(from: response.data.json())
                }
            }
        }
    }
}
