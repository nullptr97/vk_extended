import Foundation
import SwiftyJSON

/// Represents LongPoll event. More info - https://vk.com/dev/using_longpoll
public enum LongPollEvent {
    case forcedStop
    case historyMayBeLost
    case type1(data: JSON)
    case type2(data: JSON)
    case type3(data: JSON)
    case type4(data: JSON)
    case type5(data: JSON)
    case type6(data: JSON)
    case type7(data: JSON)
    case type8(data: JSON)
    case type9(data: JSON)
    case type10(data: JSON)
    case type11(data: JSON)
    case type12(data: JSON)
    case type13(data: JSON)
    case type14(data: JSON)
    case type51(data: JSON)
    case type52(data: JSON)
    case type61(data: JSON)
    case type62(data: JSON)
    case type70(data: JSON)
    case type80(data: JSON)
    case type114(data: JSON)
    
    var data: Data? {
        return associatedValue(of: self)
    }
    
    // swiftlint:disable cyclomatic_complexity next
    init?(json: JSON) {
        guard let type = json.array?.first?.int else { return nil }
        
        switch type {
        case 1:
            self = .type1(data: json)
        case 2:
            self = .type2(data: json)
        case 3:
            self = .type3(data: json)
        case 4:
            self = .type4(data: json)
        case 6:
            self = .type6(data: json)
        case 5:
            self = .type5(data: json)
        case 7:
            self = .type7(data: json)
        case 8:
            self = .type8(data: json)
        case 9:
            self = .type9(data: json)
        case 10:
            self = .type10(data: json)
        case 11:
            self = .type11(data: json)
        case 12:
            self = .type12(data: json)
        case 13:
            self = .type13(data: json)
        case 14:
            self = .type14(data: json)
        case 51:
            self = .type51(data: json)
        case 52:
            self = .type52(data: json)
        case 61:
            self = .type61(data: json)
        case 62:
            self = .type62(data: json)
        case 70:
            self = .type70(data: json)
        case 80:
            self = .type80(data: json)
        case 114:
            self = .type114(data: json)
        default:
            return nil
        }
    }
}

extension JSON {
    func data(_ path: String) -> Data? {
        let anyValue: Any? = path
        
        guard anyValue is NSArray || anyValue is NSDictionary else {
            return nil
        }
        
        return try? JSONSerialization.data(withJSONObject: anyValue as Any, options: [])
    }
}
func string(from object: Any) -> String? {
    guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
        return nil
    }
    return String(data: data, encoding: .utf8)
}
