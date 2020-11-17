//
//  Collection+Extension.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 30.10.2020.
//

import Foundation

extension ArraySlice {
    func toArray() -> [Element] {
        return Array(self)
    }
}
