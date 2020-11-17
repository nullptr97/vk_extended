//
//  SelfService.swift
//  VKExt
//
//  Created by Ярослав Стрельников on 30.07.2020.
//

import Foundation
import UIKit

class SelfService: NSObject {
    static let instance: SelfService = SelfService()

    var cellLayoutCalculator: FeedCellLayoutCalculatorProtocol = FeedCellLayoutCalculator()
    
    let dateFormatter: DateFormatter = {
        let dt = DateFormatter()
        dt.locale = Locale(identifier: "ru_RU")
        dt.dateFormat = "d MMM 'в' HH:mm"
        return dt
    }()
    
    func postDate(with date: Date) -> DateFormatter {
        let currentTime: NSNumber = NSNumber(value: Date().timeIntervalSince1970)
        let timestamp: NSNumber = NSNumber(value: date.timeIntervalSince1970)
        
        let dt = DateFormatter()
        dt.locale = Locale(identifier: "ru_RU")
        
        if timestamp.doubleValue < currentTime.doubleValue && timestamp.doubleValue > currentTime.doubleValue - 86399 {
            dt.dateFormat = "Сегодня 'в' HH:mm"
            return dt
        } else if timestamp.doubleValue < currentTime.doubleValue - 86399 && timestamp.doubleValue > currentTime.doubleValue - 172799 {
            dt.dateFormat = "Вчера 'в' HH:mm"
            return dt
        } else {
            dt.dateFormat = "d MMM 'в' HH:mm"
            return dt
        }
    }
}
