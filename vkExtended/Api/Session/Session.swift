//
//  Session.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 09.11.2020.
//

protocol ApiErrorExecutor {
    func captcha(rawUrlToImage: String, dismissOnFinish: Bool) throws
}

protocol SessionMaker: class {
    func session(id: String, sessionSaver: SessionSaver) -> Session
}

public enum SessionState: Int, Comparable, Codable {
    case destroyed = -1
    case initiated = 0
    case authorized = 1
    
    public static func == (lhs: SessionState, rhs: SessionState) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }

    public static func < (lhs: SessionState, rhs: SessionState) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

import Foundation

/// VK user session
public protocol Session: class {
    /// Internal VKExtended session identifier
    var id: String { get }
    /// Current session configuration.
    /// All requests in session inherit it
    var state: SessionState { get }
    /// Long poll client for this session
    var longPoll: LongPoll { get }
    /// token of current user
    var accessToken: Token? { get }
    /// Log in user with oAuth or VK app
    /// - parameter onSuccess: clousure which will be executed when user sucessfully logged.
    /// Returns info about logged user.
    /// - parameter onError: clousure which will be executed when logging failed.
    /// Returns cause of failure.
    func logIn(login: String, password: String, captchaSid: String?, captchaKey: String?, onSuccess: @escaping () -> (), onError: @escaping RequestCallbacks.Error)
    /// Log out user, remove all data and destroy current session
    func logOut()
}

protocol DestroyableSession: Session {
    func destroy()
}

public final class SessionImpl: Session, DestroyableSession, ApiErrorExecutor {
    public var state: SessionState {
        if id.isEmpty || token == nil {
            return .destroyed
        } else if token?.token != "invalidate" {
            return .authorized
        } else {
            return .initiated
        }
    }
    
    public lazy var longPoll: LongPoll = {
        longPollMaker.longPoll()
    }()
    
    public internal(set) var id: String
    
    private(set) var token: InvalidatableToken?
    
    public var accessToken: Token? {
        return token
    }

    private unowned var longPollMaker: LongPollMaker
    private weak var sessionSaver: SessionSaver?
    private let authorizator: Authorizator
    private weak var delegate: ExtendedVKSessionDelegate?
    private let gateQueue = DispatchQueue(label: "VKExtended.sessionQueue")
    private let queue = DispatchQueue(label: "VKExtended.authorizatorQueue")

    init(id: String, authorizator: Authorizator, sessionSaver: SessionSaver, longPollMaker: LongPollMaker, delegate: ExtendedVKSessionDelegate?) {
        self.id = id
        self.authorizator = authorizator
        self.longPollMaker = longPollMaker
        self.sessionSaver = sessionSaver
        self.delegate = delegate
        self.token = authorizator.getSavedToken(sessionId: id)
    }
    
    public func logIn(login: String, password: String, captchaSid: String? = nil, captchaKey: String? = nil, onSuccess: @escaping () -> (), onError: @escaping RequestCallbacks.Error) {
        gateQueue.async {
            self.authorizator.authorize(login: login, password: password, sessionId: self.id, revoke: true, captchaSid: captchaSid, captchaKey: captchaKey).done { token in
                self.token = token
                DispatchQueue.global().async {
                    onSuccess()
                }
            }.catch { error in
                onError(error.toVK())
            }
        }
    }
    
    public func logOut() {
        destroy()
        delegate?.vkTokenRemoved(for: id)
    }

    private func throwIfDestroyed() throws {
        guard state > .destroyed else {
            throw VKError.sessionAlreadyDestroyed(self)
        }
    }
    
    private func throwIfAuthorized() throws {
        guard state < .authorized else {
            throw VKError.sessionAlreadyAuthorized(self)
        }
    }
    
    private func throwIfNotAuthorized() throws {
        guard state >= .authorized else {
            throw VKError.sessionIsNotAuthorized(self)
        }
    }
    
    func destroy() {
        gateQueue.sync { unsafeDestroy() }
    }
    
    func captcha(rawUrlToImage: String, dismissOnFinish: Bool) throws {
        try throwIfDestroyed()
    }
    
    private func unsafeDestroy() {
        self.token = self.authorizator.reset(sessionId: self.id)
        self.id = ""
        self.sessionSaver?.saveState()
        self.sessionSaver?.removeSession()
    }
}

struct EncodedSession: Codable {
    let isDefault: Bool
    let id: String
    let token: String
}

public protocol SessionsHolder: class {
    /// Default VK user session
    var `default`: Session { get }
    
    var all: [Session] { get }
    
    // For now VKExtended does not support multisession
    // Probably, in the future it will be done
    // If you want to use more than one session, let me know about it
    // Maybe, you make PR to VKExtended ;)
    //    func make(config: SessionConfig) -> Session
    //    var all: [Session] { get }
    //    func destroy(session: Session) throws
    //    func markAsDefault(session: Session) throws
}

protocol SessionSaver: class {
    func saveState()
    func destroy(session: Session) throws
    func removeSession()
}

public final class SessionsHolderImpl: SessionsHolder, SessionSaver {
    private unowned var sessionMaker: SessionMaker
    private let sessionsStorage: SessionsStorage
    private var sessions = NSHashTable<AnyObject>(options: .strongMemory)
    
    public var `default`: Session {
        if let realDefault = storedDefault, realDefault.state > .destroyed {
            return realDefault
        }
        
        sessions.remove(storedDefault)
        return makeSession(makeDefault: true)
    }
    
    private weak var storedDefault: Session?
    
    public var all: [Session] {
        return sessions.allObjects.compactMap { $0 as? Session }
    }
    
    init(sessionMaker: SessionMaker, sessionsStorage: SessionsStorage) {
        self.sessionMaker = sessionMaker
        self.sessionsStorage = sessionsStorage
        
        restoreState()
    }
    
    public func make() -> Session {
        return makeSession()
    }
    
    @discardableResult
    private func makeSession(id: String = .random(20), makeDefault: Bool = false) -> Session {
        
        let session = sessionMaker.session(id: id, sessionSaver: self)
        
        sessions.add(session)
        
        if makeDefault {
            storedDefault = session
        }
        
        saveState()
        return session
    }
    
    public func destroy(session: Session) throws {
        if session.state == .destroyed {
            throw VKError.sessionAlreadyDestroyed(session)
        }
        
        (session as? DestroyableSession)?.destroy()
        sessions.remove(session)
    }
    
    public func markAsDefault(session: Session) throws {
        if session.state == .destroyed {
            throw VKError.sessionAlreadyDestroyed(session)
        }
        
        self.storedDefault = session
        saveState()
    }
    
    func saveState() {
        let encodedSessions = self.all.map { EncodedSession(isDefault: $0.id == storedDefault?.id, id: $0.id, token: $0.accessToken?.token ?? "invalidate") }.filter { !$0.id.isEmpty }
        
        do {
            try self.sessionsStorage.save(sessions: encodedSessions)
        }
        catch let error {
            print("VKExtended: Sessions not saved with an error: \(error)")
        }
    }
    
    private func restoreState() {
        do {
            let restored = try sessionsStorage.restore()
            
            restored.filter { !$0.id.isEmpty }.forEach { makeSession(id: $0.id, makeDefault: $0.isDefault) }
        }
        catch let error {
            print("VKExtended: Sessions not rerstored with an error: \(error)")
        }
    }
    
    public func removeSession() {
        let encodedSessions = self.all.map { EncodedSession(isDefault: $0.id == storedDefault?.id, id: $0.id, token: $0.accessToken?.token ?? "invalidate") }.filter { !$0.id.isEmpty }
        
        do {
            try self.sessionsStorage.remove(sessions: encodedSessions)
        }
        catch let error {
            print("VKExtended: Sessions not saved with an error: \(error)")
        }
    }
}
