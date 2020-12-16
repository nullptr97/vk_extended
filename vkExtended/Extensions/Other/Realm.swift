//
//  Realm.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 01.11.2020.
//

import Foundation
import RealmSwift

extension Results {
    func toArray<T>(ofType: T.Type) -> [T] {
        var array = [T]()
        for i in 0 ..< count {
            if let result = self[i] as? T {
                array.append(result)
            }
        }
        return array
    }
}
extension Realm {
    public func safeWrite(_ block: (() throws -> Void)) throws {
        
        if (isInWriteTransaction) {
            try block()
        } else {
            try write(block)
        }
    }
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
extension Results {
    public func safeObserve(_ block: @escaping (RealmCollectionChange<Results>) -> Void, completion: @escaping (NotificationToken) -> Void) {
        
        let realm = try! Realm()
        if (!realm.isInWriteTransaction) {
            let token = self.observe(block)
            completion(token)
        } else {
            DispatchQueue.main.async(after: 0.1) {
                self.safeObserve(block, completion: completion)
            }
        }
    }
}
