import Foundation
import SwiftyJSON
import Alamofire

protocol LongPollTask: OperationConvertible {}

final class LongPollTaskImpl: Operation, LongPollTask {
    private let server: String
    private var startTs: String
    private let lpKey: String
    private let delayOnError: TimeInterval
    private let onResponse: ([JSON]) -> ()
    private let onError: (LongPollTaskError) -> ()
    private let semaphore = DispatchSemaphore(value: 0)
    private let repeatQueue = DispatchQueue.global(qos: .utility)
    
    init(delayOnError: TimeInterval, data: LongPollTaskData) {
        self.server = data.server
        self.lpKey = data.lpKey
        self.startTs = data.startTs
        self.delayOnError = delayOnError
        self.onResponse = data.onResponse
        self.onError = data.onError
    }
    
    override func main() {
        update(ts: startTs)
        semaphore.wait()
    }
    
    private func update(ts: String, hasErrored: Bool = false) {
        guard !isCancelled else { return }
        if hasErrored && UserDefaults.standard.bool(forKey: "isReachable") {
            NotificationCenter.default.post(name: NSNotification.Name("onConnectingLongPoll"), object: nil)
        }
        Alamofire.request("https://\(server)?act=a_check&key=\(lpKey)&ts=\(ts)&wait=25&mode=234").downloadProgress(closure: { (progress) in
            if progress.isFinished && hasErrored {
                NotificationCenter.default.post(name: NSNotification.Name("onRefreshingLongPoll"), object: nil)
            }
        }).responseJSON { [weak self] (response) in
            guard let self = self, !self.isCancelled else { return }

            switch response.result {
            case .success(_):
                if hasErrored {
                    NotificationCenter.default.post(name: NSNotification.Name("onConnectedLongPoll"), object: nil)
                }
                
                let json = JSON(response.data!)
                if let errorCode = json["failed"].int {
                    self.handleError(code: errorCode, response: json)
                } else {
                    let newTs = json["ts"].stringValue
                    let updates: [Any] = json["updates"].array ?? []
                    
                    self.onResponse(updates.map {
                        return JSON($0)
                    })
                    
                    self.repeatQueue.async {
                        self.update(ts: newTs)
                    }
                }
            case .failure(_):
                guard !self.isCancelled else { return }
                
                self.repeatQueue.asyncAfter(deadline: .now() + self.delayOnError, execute: {
                    guard !self.isCancelled else { return }
                    self.update(ts: ts, hasErrored: true)
                })
            }
        }
    }
    
    func handleError(code: Int, response: JSON) {
        switch code {
        case 1:
            guard let newTs = response["ts"].string else {
                onError(.unknown)
                semaphore.signal()
                return
            }
            
            onError(.historyMayBeLost)
            
            repeatQueue.async { [weak self] in
                self?.update(ts: newTs, hasErrored: true)
            }
        case 2, 3:
            onError(.connectionInfoLost)
            semaphore.signal()
        default:
            onError(.unknown)
            semaphore.signal()
        }
    }
    
    override func cancel() {
        super.cancel()
        semaphore.signal()
    }
}

struct LongPollTaskData {
    let server: String
    let startTs: String
    let lpKey: String
    let onResponse: ([JSON]) -> ()
    let onError: (LongPollTaskError) -> ()
}

enum LongPollTaskError {
    case unknown
    case historyMayBeLost
    case connectionInfoLost
}
