import Foundation
import Alamofire
import SwiftyJSON

protocol LongPollTaskMaker: class {
    func longPollTask(session: Session?, data: LongPollTaskData) -> LongPollTask
    func longPollTask(data: LongPollTaskData) -> LongPollTask
}

protocol LongPollMaker: class {
    func longPoll(session: Session) -> LongPoll
}

public enum LongPollVersion: String {
    static let latest = LongPollVersion.third

    case zero = "0"
    case first = "1"
    case second = "2"
    case third = "3"
}

/// Long poll client
public protocol LongPoll {
    /// Is long poll can handle events
    var isActive: Bool { get }
    
    /// Start recieve long poll events
    /// parameters onReceiveEvents: clousure ehich executes when long poll recieve set of events
    func start(version: LongPollVersion, onReceiveEvents: @escaping ([LongPollEvent]) -> ())
    
    /// Stop recieve long poll events
    func stop()
}

extension LongPoll {
    func start(version: LongPollVersion = .latest, onReceiveEvents: @escaping ([LongPollEvent]) -> ()) {
        start(version: version, onReceiveEvents: onReceiveEvents)
    }
}

public final class LongPollImpl: LongPoll {
    
    private weak var session: Session?
    private weak var operationMaker: LongPollTaskMaker?
    private let connectionObserver: ConnectionObserver?
    private let getInfoDelay: TimeInterval
    
    private let synchronyQueue = DispatchQueue.global(qos: .userInitiated)
    private let updatingQueue: OperationQueue
    
    private let onDisconnected: (() -> ())?
    private let onConnected: (() -> ())?
    
    public var isActive: Bool
    private var isConnected = false
    private var onReceiveEvents: (([LongPollEvent]) -> ())?
    private var taskData: LongPollTaskData?
    private var version: LongPollVersion = .first
    
    init(
        session: Session?,
        operationMaker: LongPollTaskMaker,
        connectionObserver: ConnectionObserver?,
        getInfoDelay: TimeInterval,
        onConnected: (() -> ())? = nil,
        onDisconnected: (() -> ())? = nil
        ) {
        self.isActive = false
        self.session = session
        self.operationMaker = operationMaker
        self.connectionObserver = connectionObserver
        self.getInfoDelay = getInfoDelay
        self.onConnected = onConnected
        self.onDisconnected = onDisconnected
        
        self.updatingQueue = {
            let queue = OperationQueue()
            queue.maxConcurrentOperationCount = 1
            return queue
        }()
    }
    
    public func start(version: LongPollVersion, onReceiveEvents: @escaping ([LongPollEvent]) -> ()) {
        synchronyQueue.sync {
            guard !self.isActive else { return }
            
            self.onReceiveEvents = onReceiveEvents
            self.isActive = true
            self.setUpConnectionObserver()
        }
    }
    
    public func stop() {
        synchronyQueue.sync {
            guard self.isActive else { return }
            
            self.isActive = false
            self.updatingQueue.cancelAllOperations()
        }
    }
    
    private func setUpConnectionObserver() {
        connectionObserver?.subscribe(object: self, callbacks: (onConnect: { [weak self] in
            guard let self = self else { return }
            self.onConnect()
        }, onDisconnect: { [weak self] in
            guard let self = self else { return }
            self.onDisconnect()
        }))
    }
    
    private func onConnect() {
        synchronyQueue.async {
            guard !self.isConnected else { return }
            self.isConnected = true

            guard self.isActive else { return }
            self.onConnected?()
            
            if self.taskData != nil {
                self.startUpdating()
            } else {
                self.updateTaskDataAndStartUpdating()
            }
        }
    }
    
    private func onDisconnect() {
        synchronyQueue.async {
            guard self.isConnected else { return }
            
            self.isConnected = false
            
            guard self.isActive else { return }
            self.updatingQueue.cancelAllOperations()
            self.onDisconnected?()
        }
    }
    
    private func updateTaskDataAndStartUpdating() {
        getConnectionInfo { [weak self] connectionInfo in
            guard let self = self, self.isActive else { return }
            
            self.taskData = LongPollTaskData(server: connectionInfo.server, startTs: connectionInfo.ts, lpKey: connectionInfo.lpKey, onResponse: { updates in
                guard self.isActive else { return }
                let events = updates.compactMap {
                    LongPollEvent(json: $0)
                }
                self.onReceiveEvents?(events)
            }, onError: { [weak self] in
                guard let self = self else { return }
                    try! Api.Messages.getConversations().done { conversations in
                        ConversationService.instance.updateDb(by: conversations)
                    }.catch { error in
                        print(error.toVK().toApi()?.message ?? error.localizedDescription)
                    }
                self.handleError($0)
            })
            
            self.startUpdating()
        }
    }
    
    private func startUpdating() {
        updatingQueue.cancelAllOperations()
        
        guard isConnected, let data = taskData else { return }
        
        guard let operation = operationMaker?.longPollTask(session: session, data: data) else { return }
        updatingQueue.addOperation(operation.toOperation())
    }
    
    private func getConnectionInfo(completion: @escaping ((server: String, lpKey: String, ts: String)) -> ()) {
        guard let session = session, session.state == .authorized else { return }

        let semaphore = DispatchSemaphore(value: 0)
        
        var result: (server: String, lpKey: String, ts: String)?
        
        let parameters: Alamofire.Parameters = [Parameter.needPts.rawValue: 1, Parameter.lpVersion.rawValue: 3]
        
        Request.dataRequest(method: ApiMethod.method(from: .messages, with: ApiMethod.Messages.getLongPollServer), parameters: parameters).done { response in
            switch response {
            case .success(let data):
                defer { semaphore.signal() }

                let json = JSON(data)
                result = (json["server"].stringValue, json["key"].stringValue, json["ts"].stringValue)
            case .error(let error):
                print(error.localizedDescription)
                semaphore.signal()
            }
        }.catch { error in
            semaphore.signal()
        }
        
        semaphore.wait()
        
        guard let unwrappedResult = result else {
            return synchronyQueue.asyncAfter(deadline: .now() + getInfoDelay) { [weak self] in
                self?.getConnectionInfo(completion: completion)
            }
        }
        
        completion(unwrappedResult)
    }
    
    private func handleError(_ error: LongPollTaskError) {
        switch error {
        case .unknown:
            onReceiveEvents?([.forcedStop])
        case .historyMayBeLost:
            onReceiveEvents?([.historyMayBeLost])
        case .connectionInfoLost:
            updateTaskDataAndStartUpdating()
        }
    }
    
    deinit {
        connectionObserver?.unsubscribe(object: self)
    }
}
