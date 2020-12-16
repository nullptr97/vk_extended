//
//  ГШВумшсу.swift
//  VKExt
//
//  Created by Ярослав Стрельников on 21.09.2020.
//

import Foundation
import UIKit

public enum DeviceName: Int {
    case simulator   = 0,
        iPhone4          = 1,
        iPhone4S         = 2,
        iPhone5          = 3,
        iPhone5S         = 4,
        iPhone5C         = 5,
        iPhone6          = 6,
        iPhone6plus      = 7,
        iPhone6S         = 8,
        iPhone6Splus     = 9,
        iPhoneSE         = 10,
        iPhone7          = 11,
        iPhone7plus      = 12,
        iPhone8          = 13,
        iPhone8plus      = 14,
        iPhoneX          = 15,
        iPhoneXS         = 16,
        iPhoneXSmax      = 17,
        iPhoneXR         = 18,
        iPhone11         = 19,
        iPhone11Pro      = 20,
        iPhone11ProMax   = 21,
        unrecognized     = -1
}

public extension UIDevice {
    static let type: DeviceName = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String.init(validatingUTF8: ptr)
            }
        }
        let modelMap : [String : DeviceName] = [
            "i386"       : .simulator,
            "x86_64"     : .simulator,
            "iPhone3,1"  : .iPhone4,
            "iPhone3,2"  : .iPhone4,
            "iPhone3,3"  : .iPhone4,
            "iPhone4,1"  : .iPhone4S,
            "iPhone5,1"  : .iPhone5,
            "iPhone5,2"  : .iPhone5,
            "iPhone5,3"  : .iPhone5C,
            "iPhone5,4"  : .iPhone5C,
            "iPhone6,1"  : .iPhone5S,
            "iPhone6,2"  : .iPhone5S,
            "iPhone7,1"  : .iPhone6plus,
            "iPhone7,2"  : .iPhone6,
            "iPhone8,1"  : .iPhone6S,
            "iPhone8,2"  : .iPhone6Splus,
            "iPhone8,4"  : .iPhoneSE,
            "iPhone9,1"  : .iPhone7,
            "iPhone9,2"  : .iPhone7plus,
            "iPhone9,3"  : .iPhone7,
            "iPhone9,4"  : .iPhone7plus,
            "iPhone10,1" : .iPhone8,
            "iPhone10,2" : .iPhone8plus,
            "iPhone10,3" : .iPhoneX,
            "iPhone10,6" : .iPhoneX,
            "iPhone11,2" : .iPhoneXS,
            "iPhone11,4" : .iPhoneXSmax,
            "iPhone11,6" : .iPhoneXSmax,
            "iPhone11,8" : .iPhoneXR,
            "iPhone12,1" : .iPhone11,
            "iPhone12,3" : .iPhone11Pro,
            "iPhone12,5" : .iPhone11ProMax
        ]

    if let model = modelMap[String.init(validatingUTF8: modelCode!)!] {
            return model
        }
        return DeviceName.unrecognized
    }()
}
