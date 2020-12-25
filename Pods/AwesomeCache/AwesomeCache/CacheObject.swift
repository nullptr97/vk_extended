import Foundation

/// This class is a wrapper around an objects that should be cached to disk.
///
/// NOTE: It is currently not possible to use generics with a subclass of NSObject
/// 	 However, NSKeyedArchiver needs a concrete subclass of NSObject to work correctly
class CacheObject: NSObject, NSCoding {
    func encode(with coder: NSCoder) {
        coder.encode(value, forKey: "value")
        coder.encode(expiryDate, forKey: "expiryDate")
    }
    
    let value: AnyObject
    let expiryDate: Date

    /// Designated initializer.
    ///
    /// - parameter value:      An object that should be cached
    /// - parameter expiryDate: The expiry date of the given value
    init(value: AnyObject, expiryDate: Date) {
        self.value = value
        self.expiryDate = expiryDate
    }

    /// Determines if cached object is expired
    ///
    /// - returns: True If objects expiry date has passed
    func isExpired() -> Bool {
        return expiryDate.isInThePast
    }


    /// NSCoding

    required init?(coder aDecoder: NSCoder) {
        guard let val = aDecoder.decodeObject(forKey: "value") as? AnyObject,
              let expiry = aDecoder.decodeObject(forKey: "expiryDate") as? Date else {
                return nil
        }

        self.value = val
        self.expiryDate = expiry
        super.init()
    }
}

extension Date {
    var isInThePast: Bool {
        return self.timeIntervalSinceNow < 0
    }
}
