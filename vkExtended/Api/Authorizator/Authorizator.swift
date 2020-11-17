//
//  Authorizator.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 09.11.2020.
//

import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

protocol Authorizator: class {
    func getSavedToken(sessionId: String) -> InvalidatableToken?
    func authorize(login: String, password: String, sessionId: String, revoke: Bool, captchaSid: String?, captchaKey: String?) -> Promise<InvalidatableToken>
    func reset(sessionId: String) -> InvalidatableToken?
}

final class AuthorizatorImpl: Authorizator {
    private let queue = DispatchQueue(label: "VKExtended.authorizatorQueue")
    private let directAuthUrl: String = "https://oauth.vk.com/token?"
    
    private let appId: String
    private var tokenStorage: TokenStorage
    private weak var tokenMaker: TokenMaker?
    private weak var delegate: ExtendedVKAuthorizatorDelegate?
    
    private(set) var vkAppToken: InvalidatableToken?
    private var requestTimeout: TimeInterval = 10
    
    init(appId: String, delegate: ExtendedVKAuthorizatorDelegate?, tokenStorage: TokenStorage, tokenMaker: TokenMaker) {
        self.appId = appId
        self.delegate = delegate
        self.tokenStorage = tokenStorage
        self.tokenMaker = tokenMaker
    }
    
    func authorize(login: String, password: String, sessionId: String, revoke: Bool, captchaSid: String? = nil, captchaKey: String? = nil) -> Promise<InvalidatableToken> {
        defer { vkAppToken = nil }
        
        return queue.sync {
            auth(login: login, password: password, sessionId: sessionId, captchaSid: captchaSid, captchaKey: captchaKey)
        }
    }
    
    func getSavedToken(sessionId: String) -> InvalidatableToken? {
        return queue.sync {
            tokenStorage.getFor(sessionId: sessionId)
        }
    }
    
    func reset(sessionId: String) -> InvalidatableToken? {
        return queue.sync {
            tokenStorage.removeFor(sessionId: sessionId)
            return nil
        }
    }
    
    private func getToken(sessionId: String, authData: AuthData) throws -> InvalidatableToken {
        switch authData {
        case .sessionInfo(accessToken: let accessToken, userId: let userId):
            UserDefaults.standard.set(userId, forKey: "userId")
            let token = try makeToken(token: accessToken)
            try tokenStorage.save(token, for: sessionId)
            return token
        }
    }

    private func makeToken(token: String) throws -> InvalidatableToken {
        guard let tokenMaker = tokenMaker else {
            throw VKError.weakObjectWasDeallocated
        }
        
        return tokenMaker.token(token: token)
    }
    
    private var settings: String {
        return "notify,friends,photos,audio,video,docs,status,notes,pages,wall,groups,messages,offline,notifications"
    }
    
    func parameters(login: String, password: String) -> Alamofire.Parameters {
        let parameters: Alamofire.Parameters = [
            "grant_type": "password",
            "client_id": Constants.appId,
            "client_secret": Constants.clientSecret,
            "username": login,
            "password": password,
            "v": 5.124,
            "scope": settings,
            "lang": "ru",
            "2fa_supported": 1
        ]
        return parameters
    }
    
    func auth(login: String, password: String, sessionId: String, captchaSid: String? = nil, captchaKey: String? = nil) -> Promise<InvalidatableToken> {
        var alamofireParameters = parameters(login: login, password: password)
        let sortedKeys = Array(alamofireParameters.keys).sorted(by: <)
        
        var stringForMD5 = ""
        
        for key in sortedKeys {
            stringForMD5 = stringForMD5 + key + "=\(alamofireParameters[key] ?? "")&"
        }
        if stringForMD5.last! == "&" {
            stringForMD5.remove(at: stringForMD5.index(before: stringForMD5.endIndex))
        }
        if let captchaSid = captchaSid, let captchaKey = captchaKey {
            alamofireParameters["captcha_sid"] = captchaSid
            alamofireParameters["captcha_key"] = captchaKey
        }
        alamofireParameters["sig"] = MD5.MD5(stringForMD5)
        
        return firstly {
            Alamofire.request(directAuthUrl, method: .post, parameters: alamofireParameters).responseJSON()
        }.compactMap {
            let json = JSON($0.json)
            let error = json["error"]
            if error != JSON.null {
                switch error.stringValue {
                case ErrorType.capthca.rawValue:
                    throw VKError.needCaptcha(captchaImg: json["captcha_img"].stringValue, captchaSid: json["captcha_sid"].stringValue)
                case ErrorType.incorrectLoginPassword.rawValue:
                    throw VKError.incorrectLoginPassword
                default:
                    throw VKError.authorizationFailed
                }
            } else {
                return try self.getToken(sessionId: sessionId, authData: AuthData.sessionInfo(accessToken: json["access_token"].stringValue, userId: json["user_id"].intValue))
            }
        }
    }
}