import UIKit
import Foundation

extension APIScope {
    /// https://vk.com/dev/polls
    public enum Polls: APIMethod {
        case addVote
        case create
        case deleteVote
        case edit
        case getById
        case getVoters
    }
}
