//
//  Token.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 09.11.2020.
//

import Foundation

protocol TokenMaker: class {
    func token(token: String) -> InvalidatableToken
}

public protocol Token: class {
    var token: String { get }
    
    func get() -> String
}

protocol InvalidatableToken: NSCoding, Token {
    func invalidate()
}

final class TokenImpl: NSObject, InvalidatableToken {
    public internal(set) var token: String
    
    init(token: String) {
        self.token = token
    }
    
    func get() -> String {
        return token
    }
    
    func invalidate() {
        token = "invalidate"
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(token, forKey: "token")
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let token = aDecoder.decodeObject(forKey: "token") as? String else { return nil }
        
        self.token = token
    }
}
