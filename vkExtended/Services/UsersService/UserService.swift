//
//  UserService.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 01.11.2020.
//

import Foundation
import SwiftyJSON
import RealmSwift
import UIKit

class UserService: NSObject {
    static let instance = UserService()
    
//    func getUserName(userId: Int, nameCase: NameCase, isShortName: Bool, completion: ((String?, VKError?) -> Void)?) {
//        VK.API.Users.get([.userId: "\(userId)", .nameCase: nameCase.rawValue])
//            .configure(with: Config.init(httpMethod: .GET, language: Language(rawValue: "ru")))
//            .onSuccess { response in
//                guard let completion = completion else { return }
//                var name: String = ""
//                if isShortName {
//                    name = JSON(response)[0]["first_name"].stringValue
//                } else {
//                    name = "\(JSON(response)[0]["first_name"].stringValue) \(JSON(response)[0]["last_name"].stringValue)"
//                }
//                completion(name, nil)
//        }
//        .onError { error in
//            guard let completion = completion else { return }
//            completion(nil, error)
//        }
//        .send()
//    }
//    
//    func getUserPhoto(userId: Int, completion: ((String?, String?, String?, VKError?) -> Void)?) {
//        DispatchQueue.afterDelay(with: 1.2, execute: {
//            VK.API.Users.get([.userId: "\(userId)", .fields: "photo_100"])
//                .configure(with: Config.init(httpMethod: .GET, language: Language(rawValue: "ru")))
//                .onSuccess { response in
//                    guard let completion = completion else { return }
//                    completion(JSON(response)[0]["photo_100"].stringValue, "\(JSON(response)[0]["first_name"].stringValue)", "\(JSON(response)[0]["last_name"].stringValue)", nil)
//            }
//            .onError { error in
//                guard let completion = completion else { return }
//                completion(nil, nil, nil, error)
//            }
//            .send()
//        })
//    }
    
    func getPeer(by id: Int) -> ConversationPeerType {
        if id >= 2000000000 {
            return .chat
        } else if id >= 1000000000 {
            return .group
        } else {
            return .user
        }
    }
    
    func getNewPeerId(by id: Int) -> Int {
        if id == id {
            return id
        } else if id > (id + 1000000000) {
            return (id + 1000000000) * -1
        } else {
            return id + 2000000000
        }
    }
}

