//
//  NSMutableAttributedString.swift
//  VKExt
//
//  Created by programmist_NA on 22.05.2020.
//

import Foundation
import UIKit
import Kingfisher

public extension NSMutableAttributedString {
    @discardableResult
    func bold(_ text: String, fontSize: CGFloat = UIFont.preferredFont(forTextStyle: .body).pointSize, textColor: UIColor = .black) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key:AnyObject] = [
            NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: fontSize),
            NSAttributedString.Key.foregroundColor : textColor
        ]
        let boldString = NSMutableAttributedString(string: text, attributes: attrs)
        self.append(boldString)
        return self
    }
    
    @discardableResult
    func medium(_ text: String, fontSize: CGFloat = UIFont.preferredFont(forTextStyle: .body).pointSize, textColor: UIColor = .black) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key:AnyObject] = [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: fontSize, weight: UIFont.Weight.medium),
            NSAttributedString.Key.foregroundColor : textColor
        ]
        let mediumString = NSMutableAttributedString(string: text, attributes: attrs)
        self.append(mediumString)
        return self
    }
    
    @discardableResult
    func italic(_ text: String, fontSize: CGFloat = UIFont.preferredFont(forTextStyle: .body).pointSize, textColor: UIColor = .black) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key:AnyObject] = [
            NSAttributedString.Key.font : UIFont.italicSystemFont(ofSize: fontSize),
            NSAttributedString.Key.foregroundColor : textColor
        ]
        let italicString = NSMutableAttributedString(string: text, attributes: attrs)
        self.append(italicString)
        return self
    }
    
    @discardableResult
    func normal(_ text: String, fontSize: CGFloat = UIFont.preferredFont(forTextStyle: .body).pointSize, textColor: UIColor = .black) -> NSMutableAttributedString {
        let attrs:[NSAttributedString.Key:AnyObject] = [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: fontSize),
            NSAttributedString.Key.foregroundColor : textColor
        ]
        let normal =  NSMutableAttributedString(string: text, attributes: attrs)
        self.append(normal)
        return self
    }
}

public extension NSAttributedString {
    func replacingCharacters(in range: NSRange, with attributedString: NSAttributedString) -> NSMutableAttributedString {
        let ns = NSMutableAttributedString(attributedString: self)
        ns.replaceCharacters(in: range, with: attributedString)
        return ns
    }
    
    static func += (lhs: inout NSAttributedString, rhs: NSAttributedString) {
        let ns = NSMutableAttributedString(attributedString: lhs)
        ns.append(rhs)
        lhs = ns
    }
    
    static func + (lhs: NSAttributedString, rhs: NSAttributedString) -> NSAttributedString {
        let ns = NSMutableAttributedString(attributedString: lhs)
        ns.append(rhs)
        return NSAttributedString(attributedString: ns)
    }
    
    func withLineSpacing(_ spacing: CGFloat) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(attributedString: self)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.lineSpacing = spacing
        attributedString.addAttribute(.paragraphStyle,
                                      value: paragraphStyle,
                                      range: NSRange(location: 0, length: string.count))
        return NSAttributedString(attributedString: attributedString)
    }
}
func setLabelImage(image: String) -> NSMutableAttributedString? {
    let imageAttachment = NSTextAttachment()
    if image == "online_mobile_composite_foreground_20" {
        imageAttachment.image = UIImage(named: image)?.withRenderingMode(.alwaysTemplate).tint(with: .getThemeableColor(fromNormalColor: .darkGray))?.resize(toWidth: 9)?.resize(toHeight: 14)
    } else if image == "done_16" || image == "logo_vkme_16" || image == "download_outline_16" {
        imageAttachment.image = UIImage(named: image)?.withRenderingMode(.alwaysTemplate).tint(with: .getAccentColor(fromType: .common))
    } else if image == "favorite_24" || image == "flash_16" {
        imageAttachment.image = UIImage(named: image)?.withRenderingMode(.alwaysTemplate).tint(with: .adaptableOrange)?.resize(toWidth: 16)?.resize(toHeight: 16)
    } else if image == "write_24" {
        imageAttachment.image = UIImage(named: image)?.withRenderingMode(.alwaysTemplate).tint(with: .getThemeableColor(fromNormalColor: .darkGray))?.resize(toWidth: 12)?.resize(toHeight: 12)
    } else {
        imageAttachment.image = UIImage(named: image)
    }
    // Set bound to reposition
    if image == "online_mobile_composite_foreground_20" {
        imageAttachment.bounds = CGRect(x: 0, y: 0, width: 7, height: 12)
    } else if image == "verified_16" {
        imageAttachment.bounds = CGRect(x: 0, y: -2, width: 16, height: 16)
    } else if image == "flash_16" {
        imageAttachment.bounds = CGRect(x: -5, y: -3, width: 16, height: 16)
    } else if image == "favorite_24" {
        imageAttachment.bounds = CGRect(x: -4, y: -2, width: 16, height: 16)
    } else if image == "write_24" {
        imageAttachment.bounds = CGRect(x: -4, y: 0, width: 10, height: 10)
    } else if image == "download_outline_16" {
        imageAttachment.bounds = CGRect(x: 0, y: -3, width: 16, height: 16)
    } else {
        imageAttachment.bounds = CGRect(x: 0, y: 0, width: imageAttachment.image!.size.width, height: imageAttachment.image!.size.height)
    }
    // Create string with attachment
    let attachmentString = NSAttributedString(attachment: imageAttachment)
    // Initialize mutable string
    let completeText = NSMutableAttributedString(string: " ")
    // Add image to mutable string
    completeText.append(attachmentString)
    
    return completeText
}
func setLabelImage(image: UIImage?) -> NSMutableAttributedString? {
    let imageAttachment = NSTextAttachment()
    imageAttachment.image = image
    imageAttachment.bounds = CGRect(x: 0, y: -4, width: 20, height: 20)
    // Create string with attachment
    let attachmentString = NSAttributedString(attachment: imageAttachment)
    // Initialize mutable string
    let completeText = NSMutableAttributedString(string: " ")
    // Add image to mutable string
    completeText.append(attachmentString)
    
    return completeText
}
func setLabelImage(imgStatusUrl: URL) -> NSMutableAttributedString? {
    let imageAttachment = NSTextAttachment()
    
    KingfisherManager.shared.retrieveImage(with: imgStatusUrl) { result in
        switch result {
        case .success(let value):
            imageAttachment.image = value.image
            imageAttachment.bounds = CGRect(x: 0, y: -4, width: 20, height: 20)
        case .failure(let error):
            print(error.localizedDescription)
        }
    }

    // Create string with attachment
    let attachmentString = NSAttributedString(attachment: imageAttachment)

    // Initialize mutable string
    let completeText = NSMutableAttributedString(string: " ")
    
    // Add image to mutable string
    completeText.append(attachmentString)
    
    let customAttribute = [NSAttributedString.Key.imagePath: imageAttachment]
    completeText.addAttributes(customAttribute, range: NSRange(location: 0, length: completeText.length))
    
    return completeText
}

extension NSAttributedString.Key {
    static let imagePath = NSAttributedString.Key(rawValue: "imagePath")
}
