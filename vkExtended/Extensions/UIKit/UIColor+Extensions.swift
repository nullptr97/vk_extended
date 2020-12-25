//
//  UIColor+Extensions.swift
//  ExtendedKit
//
//  Created by Ярослав Стрельников on 19.10.2020.
//

import Foundation
import UIKit

public enum AccentColorType {
    case button
    case secondaryButton
    case common
}

struct ExtendedColors {
    static let white = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1)
    static let smoke = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1)
    static let lightGray = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
    static let gray = UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1)
    static let grayVK = #colorLiteral(red: 0.6823529412, green: 0.7176470588, blue: 0.7607843137, alpha: 1)
    static let middleGray = #colorLiteral(red: 0, green: 0.1098039216, blue: 0.2392156863, alpha: 0.0515036387)
    static let darkGray = UIColor(red: 0.92, green: 0.92, blue: 0.92, alpha: 1)
    static let smokeBlue = #colorLiteral(red: 0.6823529412, green: 0.7176470588, blue: 0.7607843137, alpha: 1)
    static let metal = UIColor(red: 0.71, green: 0.71, blue: 0.71, alpha: 1)
    static let dark = UIColor(red: 0.55, green: 0.55, blue: 0.55, alpha: 1)
    static let black = UIColor.color(from: 0x19191A)
    static let darkGrape = UIColor(red: 0.2, green: 0.2, blue: 0.27, alpha: 1)
    static let grape = UIColor(red: 0.22, green: 0.23, blue: 0.3, alpha: 1)
    static let sea = UIColor(red: 0.15, green: 0.45, blue: 0.66, alpha: 1)
    static let sapphire = UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1)
    static let blue = UIColor.color(from: 0x3F8AE0)
    static let green = #colorLiteral(red: 0.2941176471, green: 0.7019607843, blue: 0.2941176471, alpha: 1)
    static let yellow = UIColor(red: 1.0, green: 0.87, blue: 0.35, alpha: 1)
    static let orange = UIColor(red: 1.0, green: 0.67, blue: 0.2, alpha: 1)
    static let red = UIColor(red: 1.0, green: 0.42, blue: 0.39, alpha: 1)
    static let space = UIColor.color(from: 0x262626)
    static let secondary = UIColor.color(from: 0x8A96B4)
}

extension UIColor {
    var isLight: Bool {
        var white: CGFloat = 0
        getWhite(&white, alpha: nil)
        return white > 0.5
    }
    
    var inverted: UIColor {
        var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0
        UIColor.red.getRed(&r, green: &g, blue: &b, alpha: &a)
        return UIColor(red: (1 - r), green: (1 - g), blue: (1 - b), alpha: a)
    }
    
    class func color(from hex: UInt32) -> UIColor {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 256.0
        let green = CGFloat((hex & 0xFF00) >> 8) / 256.0
        let blue = CGFloat(hex & 0xFF) / 256.0
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    class var adaptableTextPrimaryColor: UIColor {
        if #available(iOS 13, *) {
        return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
            switch UITraitCollection.userInterfaceStyle {
            case .unspecified:
                return ExtendedColors.white
            case .light:
                return ExtendedColors.space
            case .dark:
                return ExtendedColors.white
            @unknown default:
                return ExtendedColors.space
            }
        }
        } else {
            return ExtendedColors.space
        }
    }
    
    class var adaptableTextSecondaryColor: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                switch UITraitCollection.userInterfaceStyle {
                default:
                    return ExtendedColors.secondary
                }
            }
        } else {
            return ExtendedColors.secondary
        }
    }
    
    class var adaptablePostColor: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                switch UITraitCollection.userInterfaceStyle {
                case .unspecified:
                    return .color(from: 0x161617)
                case .light:
                    return .color(from: 0xF5F5F5)
                case .dark:
                    return .color(from: 0x161617)
                @unknown default:
                    return .color(from: 0xF5F5F5)
                }
            }
        } else {
            return .color(from: 0xF5F5F5)
        }
    }

    class var adaptableWhite: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                if UITraitCollection.userInterfaceStyle == .dark {
                    return !UserDefaults.standard.bool(forKey: "isAmoledTheme") ? .black : ExtendedColors.black
                } else {
                    return ExtendedColors.white
                }
            }
        } else {
            return ExtendedColors.white
        }
    }
    
    class var adaptableSeparator: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                if UITraitCollection.userInterfaceStyle == .dark {
                    return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.1235145246)
                } else {
                    return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1205160651)
                }
            }
        } else {
            return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1213413292)
        }
    }
    
    class var adaptableField: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                if UITraitCollection.userInterfaceStyle == .dark {
                    return UIColor.black.withAlphaComponent(0.12)
                } else {
                    return color(from: 0xF2F3F5)
                }
            }
        } else {
            return color(from: 0xF2F3F5)
        }
    }
    
    class var adaptableTextView: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                if UITraitCollection.userInterfaceStyle == .dark {
                    return .color(from: 0x2C2D2E)
                } else {
                    return color(from: 0xf8f9fa)
                }
            }
        } else {
            return color(from: 0xf8f9fa)
        }
    }
    
    class var adaptableBorder: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                if UITraitCollection.userInterfaceStyle == .dark {
                    return UIColor.white.withAlphaComponent(0.12)
                } else {
                    return UIColor.black.withAlphaComponent(0.12)
                }
            }
        } else {
            return UIColor.black.withAlphaComponent(0.12)
        }
    }
    
    class var adaptableError: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                if UITraitCollection.userInterfaceStyle == .dark {
                    return .color(from: 0x522E2E)
                } else {
                    return .color(from: 0xFAEBEB)
                }
            }
        } else {
            return .color(from: 0xFAEBEB)
        }
    }
    
    class var extendedSmoke: UIColor {
        return ExtendedColors.smoke
    }
    
    class var adaptableLightGray: UIColor {
        return ExtendedColors.lightGray
    }
    
    class var extendedGray: UIColor {
        return ExtendedColors.gray
    }
    
    class var adaptableGrayVK: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                if UITraitCollection.userInterfaceStyle == .dark {
                    return UIColor.color(from: 0x818C99)
                } else {
                    return ExtendedColors.grayVK
                }
            }
        } else {
            return ExtendedColors.grayVK
        }
    }
    
    class var adaptableDarkGrayVK: UIColor {
        return UIColor.color(from: 0x818C99)
    }
    
    class var extendedPlaceholderText: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                if UITraitCollection.userInterfaceStyle == .dark {
                    return .color(from: 0xAAAEB3)
                } else {
                    return .color(from: 0x818C99)
                }
            }
        } else {
            return .color(from: 0x818C99)
        }
    }
    
    class var extendedDarkGray: UIColor {
        return ExtendedColors.darkGray
    }
    
    class var adaptableSmokeBlue: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                if UITraitCollection.userInterfaceStyle == .dark {
                    return .color(from: 0x2C2D2E)
                } else {
                    return .color(from: 0xE1E3E6)
                }
            }
        } else {
            return .color(from: 0xE1E3E6)
        }
    }
    
    class var extendedMetal: UIColor {
        return ExtendedColors.metal
    }
    
    class var extendedDark: UIColor {
        return ExtendedColors.dark
    }
    
    class var adaptableBlack: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                if UITraitCollection.userInterfaceStyle == .dark {
                    return ExtendedColors.white
                } else {
                    return ExtendedColors.black
                }
            }
        } else {
            return ExtendedColors.black
        }
    }
    
    class var extendedDarkGrape: UIColor {
        return ExtendedColors.darkGrape
    }
    
    class var extendedGrape: UIColor {
        return ExtendedColors.grape
    }
    
    class var extendedSea: UIColor {
        return ExtendedColors.sea
    }
    
    class var adaptableDivider: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                if UITraitCollection.userInterfaceStyle == .dark {
                    return .color(from: 0x2C2D2E)
                } else {
                    return .color(from: 0xE1E3E6)
                }
            }
        } else {
            return .color(from: 0xE1E3E6)
        }
    }
    
    class var adaptableCard: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                if UITraitCollection.userInterfaceStyle == .dark {
                    return .color(from: 0x232323)
                } else {
                    return .color(from: 0xf2f3f5)
                }
            }
        } else {
            return .color(from: 0xf2f3f5)
        }
    }
    
    class var extendedSapphire: UIColor {
        return ExtendedColors.sapphire
    }
    
    class var extendedBlue: UIColor {
        return ExtendedColors.blue
    }
    
    class var adaptableBlue: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                if UITraitCollection.userInterfaceStyle == .dark {
                    return ExtendedColors.white
                } else {
                    return ExtendedColors.blue
                }
            }
        } else {
            return ExtendedColors.blue
        }
    }
    
    class var adaptableBackground: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                if UITraitCollection.userInterfaceStyle == .dark {
                    return .color(from: 0x0a0a0a)
                } else {
                    return UIColor.color(from: 0xecedf1)
                }
            }
        } else {
            return UIColor.color(from: 0xecedf1)
        }
    }
    
    class var adaptableButtonColor: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                if UITraitCollection.userInterfaceStyle == .dark {
                    return UIColor.color(from: 0x2c2d2f)
                } else {
                    return UIColor.color(from: 0xf1f2f4)
                }
            }
        } else {
            return UIColor.color(from: 0xf1f2f4)
        }
    }
    
    class var adaptableMutedButtonColor: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                if UITraitCollection.userInterfaceStyle == .dark {
                    return .color(from: 0x232325)
                } else {
                    return UIColor.color(from: 0xf8f8f8)
                }
            }
        } else {
            return UIColor.color(from: 0xf8f8f8)
        }
    }
    
    class var extendedGreen: UIColor {
        return ExtendedColors.green
    }
    
    class var extendedYellow: UIColor {
        return ExtendedColors.yellow
    }
    
    class var extendedOrange: UIColor {
        return ExtendedColors.orange
    }
    
    class var extendedSpace: UIColor {
        return ExtendedColors.space
    }
    
    class var adaptableOrange: UIColor {
        return .color(from: 0xFFA000)
    }
    
    class var adaptableViolet: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                if UITraitCollection.userInterfaceStyle == .dark {
                    return .color(from: 0xA393F5)
                } else {
                    return .color(from: 0x792EC0)
                }
            }
        } else {
            return .color(from: 0x792EC0)
        }
    }
    
    class var extendedRed: UIColor {
        .color(from: 0xFAEBEB)
    }
    
    class var extendedBackgroundRed: UIColor {
        .color(from: 0xE64646)
    }
    
    public static var random: UIColor {
        srandom(arc4random())
        var red: Double = 0
        
        while (red < 0.1 || red > 0.84) {
            red = drand48()
        }
        
        var green: Double = 0
        while (green < 0.1 || green > 0.84) {
            green = drand48()
        }
        
        var blue: Double = 0
        while (blue < 0.1 || blue > 0.84) {
            blue = drand48()
        }
        
        return .init(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1.0)
    }
    
    public static func colorHash(name: String?) -> UIColor {
        guard let name = name else {
            return .red
        }
        
        var nameValue = 0
        for character in name {
            let characterString = String(character)
            let scalars = characterString.unicodeScalars
            nameValue += Int(scalars[scalars.startIndex].value)
        }
        
        var r = Float((nameValue * 123) % 51) / 51
        var g = Float((nameValue * 321) % 73) / 73
        var b = Float((nameValue * 213) % 91) / 91
        
        let defaultValue: Float = 0.84
        r = min(max(r, 0.1), defaultValue)
        g = min(max(g, 0.1), defaultValue)
        b = min(max(b, 0.1), defaultValue)
        
        return .init(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: 1.0)
    }
}

public extension UIColor {
    class func getThemeableColor(fromNormalColor color: UIColor) -> UIColor {
        if #available(iOS 13, *) {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                switch color {
                case .white:
                    return .adaptableWhite
                case .black:
                    return .adaptableBlack
                case .gray:
                    return .adaptableGrayVK
                case .darkGray:
                    return .adaptableDarkGrayVK
                case .lightGray:
                    return .adaptableDivider
                case .blue:
                    return .adaptableBlue
                default:
                    return .clear
                }
            }
        } else {
            switch color {
            case .white:
                return ExtendedColors.white
            case .black:
                return ExtendedColors.black
            case .gray:
                return ExtendedColors.grayVK
            case .darkGray:
                return .adaptableDarkGrayVK
            case .lightGray:
                return .color(from: 0xE1E3E6)
            case .blue:
                return .extendedBlue
            default:
                return .clear
            }
        }
    }
    
    class func getAccentColor(fromType type: AccentColorType) -> UIColor {
        if #available(iOS 13, *) {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                switch type {
                case .common:
                    return .extendedBlue
                case .secondaryButton:
                    return UITraitCollection.userInterfaceStyle == .dark ? UIColor.white.withAlphaComponent(0.1) : UIColor.color(from: 0x001C3D).withAlphaComponent(0.05)
                case .button:
                    return UITraitCollection.userInterfaceStyle == .dark ? .white : .color(from: 0x4986CC)
                }
            }
        } else {
            switch type {
            case .common:
                return .extendedBlue
            case .secondaryButton:
                return UIColor.color(from: 0x001C3D).withAlphaComponent(0.05)
            case .button:
                return .color(from: 0x4986CC)
            }
        }
    }
    
    class var searchColor: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                return UITraitCollection.userInterfaceStyle == .dark ? .color(from: 0x363738) : .color(from: 0xEBEDF0)
            }
        } else {
            return .color(from: 0xEBEDF0)
        }
    }
}
extension UIColor {
    struct Themeable {
        static var dynamicBlue: UIColor {
            return .color(from: 0x3F8AE0)
        }
        
        static var dynamicGray: UIColor {
            return .color(from: 0xA3ADB8)
        }
        
        static var dynamicRed: UIColor {
            return .color(from: 0xff3347)
        }
        
        static var dynamicGreen: UIColor {
            return .color(from: 0x4BB34B)
        }
        
        static var dynamicOrange: UIColor {
            return .color(from: 0xFFA000)
        }
        
        static var dynamicViolet: UIColor {
            if #available(iOS 13, *) {
                return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                    if UITraitCollection.userInterfaceStyle == .dark {
                        return .color(from: 0xA393F5)
                    } else {
                        return .color(from: 0x792EC0)
                    }
                }
            } else {
                return .color(from: 0x792EC0)
            }
        }
    }
}
