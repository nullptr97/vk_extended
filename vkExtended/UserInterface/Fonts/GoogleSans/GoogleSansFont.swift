//
//  GoogleSansFont.swift
//  VK Tosters
//
//  Created by programmist_np on 31.03.2020.
//  Copyright © 2020 programmist_np. All rights reserved.
//

import UIKit

enum FontsNames: String {
    case bold = "SFProRounded-Bold"
    case light = "SFProRounded-Light"
    case medium = "SFProRounded-Medium"
    case semibold = "SFProRounded-Semibold"
    case heavy = "SFProRounded-Heavy"
    case regular = "SFProRounded-Regular"
    case thin = "SFProRounded-Thin"
}

public struct GoogleSansFont: FontType {
    /// Size of font.
    public static var pointSize: CGFloat {
        return Font.pointSize
    }
    
    /// Thin font.
    public static var thin: UIFont {
        return thin(with: Font.pointSize)
    }
    
    /// Light font.
    public static var light: UIFont {
        return light(with: Font.pointSize)
    }
    
    /// Regular font.
    public static var regular: UIFont {
        return regular(with: Font.pointSize)
    }
    
    /// Medium font.
    public static var medium: UIFont {
        return medium(with: Font.pointSize)
    }
    
    /// Semibold font.
    public static var semibold: UIFont {
        return semibold(with: Font.pointSize)
    }
    
    /// Heavy font.
    public static var heavy: UIFont {
        return heavy(with: Font.pointSize)
    }
    
    /// Bold font.
    public static var bold: UIFont {
        return bold(with: Font.pointSize)
    }
    
    /**
     Thin with size font.
     - Parameter with size: A CGFLoat for the font size.
     - Returns: A UIFont.
     */
    public static func thin(with size: CGFloat) -> UIFont {
        if let f = UIFont(name: FontsNames.thin.rawValue, size: size) {
            return f
        }
        
        return Font.systemFont(ofSize: size)
    }
    
    /**
     Light with size font.
     - Parameter with size: A CGFLoat for the font size.
     - Returns: A UIFont.
     */
    public static func light(with size: CGFloat) -> UIFont {
        if let f = UIFont(name: FontsNames.light.rawValue, size: size) {
            return f
        }
        
        return Font.systemFont(ofSize: size)
    }
    
    /**
     Regular with size font.
     - Parameter with size: A CGFLoat for the font size.
     - Returns: A UIFont.
     */
    public static func regular(with size: CGFloat) -> UIFont {
        if let f = UIFont(name: FontsNames.regular.rawValue, size: size) {
            return f
        }
        
        return Font.systemFont(ofSize: size)
    }
    
    /**
     Medium with size font.
     - Parameter with size: A CGFLoat for the font size.
     - Returns: A UIFont.
     */
    public static func medium(with size: CGFloat) -> UIFont {
        if let f = UIFont(name: FontsNames.medium.rawValue, size: size) {
            return f
        }
        
        return Font.boldSystemFont(ofSize: size)
    }
    
    
    /**
     Semibold with size font.
     - Parameter with size: A CGFLoat for the font size.
     - Returns: A UIFont.
     */
    public static func semibold(with size: CGFloat) -> UIFont {
        if let f = UIFont(name: FontsNames.semibold.rawValue, size: size) {
            return f
        }
        
        return Font.boldSystemFont(ofSize: size)
    }
    
    /**
     Heavy with size font.
     - Parameter with size: A CGFLoat for the font size.
     - Returns: A UIFont.
     */
    public static func heavy(with size: CGFloat) -> UIFont {
        if let f = UIFont(name: FontsNames.heavy.rawValue, size: size) {
            return f
        }
        
        return Font.boldSystemFont(ofSize: size)
    }
    
    /**
     Bold with size font.
     - Parameter with size: A CGFLoat for the font size.
     - Returns: A UIFont.
     */
    public static func bold(with size: CGFloat) -> UIFont {
        if let f = UIFont(name: FontsNames.bold.rawValue, size: size) {
            return f
        }
        
        return Font.boldSystemFont(ofSize: size)
    }
}
