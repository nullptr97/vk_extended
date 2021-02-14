//
//  UIView+Extensions.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 19.10.2020.
//

import Foundation
import UIKit

enum VKButtonStyle: Int, CaseIterable {
    case primary = 1
    case secondary = 2
    case secondaryMuted = 3
    case tertiary = 4
    case outline = 5
}

enum VKButtonSize: Int, CaseIterable {
    case small = 1
    case medium = 2
    case large = 3
}

extension UIButton {
    func setStyle(_ style: VKButtonStyle, with size: VKButtonSize) {
        setCorners(radius: 10)

        titleLabel?.adjustsFontSizeToFitWidth = true
        titleLabel?.allowsDefaultTighteningForTruncation = true
        
        switch size {
        case .small:
            contentEdgeInsets = .custom(5.5, 5, 6.5, 5)
            titleLabel?.font = GoogleSansFont.medium(with: 14)
        case .medium:
            contentEdgeInsets = .custom(7.5, 8, 8.5, 8)
            titleLabel?.font = GoogleSansFont.medium(with: 15)
        case .large:
            contentEdgeInsets = .custom(10.5, 12, 11.5, 12)
            titleLabel?.font = GoogleSansFont.medium(with: 17)
        }

        switch style {
        case .primary:
            backgroundColor = traitCollection.userInterfaceStyle == .dark ? .color(from: 0xE1E3E6) : .color(from: 0x3F8AE0)
            setTitleColor(.getThemeableColor(fromNormalColor: .white), for: .normal)
        case .secondary:
            backgroundColor = .getAccentColor(fromType: .secondaryButton)
            setTitleColor(traitCollection.userInterfaceStyle == .dark ? .color(from: 0xE1E3E6) : .color(from: 0x3F8AE0), for: .normal)
        case .secondaryMuted:
            backgroundColor = traitCollection.userInterfaceStyle == .dark ? .color(from: 0x2C2D2E) : .color(from: 0xF2F3F5)
            setTitleColor(traitCollection.userInterfaceStyle == .dark ? .color(from: 0xE1E3E6) : .color(from: 0x3F8AE0), for: .normal)
        case .tertiary:
            backgroundColor = .clear
            setTitleColor(traitCollection.userInterfaceStyle == .dark ? .color(from: 0xE1E3E6) : .color(from: 0x3F8AE0), for: .normal)
        case .outline:
            drawBorder(10, width: 1, color: traitCollection.userInterfaceStyle == .dark ? .color(from: 0xE1E3E6) : .color(from: 0x3F8AE0))
            backgroundColor = .clear
            setTitleColor(traitCollection.userInterfaceStyle == .dark ? .color(from: 0xE1E3E6) : .color(from: 0x3F8AE0), for: .normal)
        }
    }
}

extension UIView {
    func prepareBackground() {
        backgroundColor = .getThemeableColor(fromNormalColor: .white)
    }
    // Добавление блюра к View
    func setBlurBackground(style: UIBlurEffect.Style, frame: CGRect = .zero) {
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = frame == .zero ? bounds : frame
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(blurView, at: 0)
    }

    // Добавление блюра к View
    func blurry() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurView)
    }
    
    // Задать скругления
    func setCorners(radius: CGFloat) {
        layer.masksToBounds = true
        layer.cornerRadius = radius
    }
    
    // Задать скругления
    func setCorners(radius: CGFloat, isOnlyTopCorners: Bool = false, isOnlyBottomCorners: Bool = false, isAllCorners: Bool = true) {
        layer.masksToBounds = true
        layer.cornerRadius = radius
        if isAllCorners {
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        if isOnlyTopCorners {
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        if isOnlyBottomCorners {
            layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
    }
    
    // Сделать круглым
    func setRounded(with border: CGFloat = 0) {
        layer.masksToBounds = true
        layer.cornerRadius = bounds.size.height / 2
        if border > 0 {
            layer.shouldRasterize = false
            layer.rasterizationScale = 2
            layer.borderWidth = border
//            layer.borderColor = UIColor.adaptableDivider.cgColor
        }
    }
    
    // Сделать обводку
    func setBorder(_ radius: CGFloat, width: CGFloat, color: UIColor = UIColor.clear) {
        layer.masksToBounds = true
        layer.cornerRadius = CGFloat(radius)
        layer.shouldRasterize = false
        layer.rasterizationScale = 2
        layer.borderWidth = width
        layer.borderColor = color.cgColor
    }
    
    func drawBorder(_ radius: CGFloat, width: CGFloat, color: UIColor = UIColor.clear, isOnlyTopCorners: Bool = false) {
        layer.masksToBounds = true
        layer.cornerRadius = CGFloat(radius)
        layer.maskedCorners = isOnlyTopCorners ?
            [.layerMinXMinYCorner, .layerMaxXMinYCorner] :
            [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        layer.borderWidth = width
        layer.shouldRasterize = false
        layer.borderColor = color.cgColor
        clipsToBounds = true
    }
    
    func addWrapper(from width: CGFloat = 2, colors: Set<UIColor> = [.getAccentColor(fromType: .common), .getAccentColor(fromType: .common)]) {
        fadeTransition(0.3)
        let externalBorderLayer = CAGradientLayer()
        externalBorderLayer.frame = bounds
        externalBorderLayer.cornerRadius = externalBorderLayer.frame.height / 2
        externalBorderLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        externalBorderLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        externalBorderLayer.colors = colors.map { $0.cgColor }
        
        let shape = CAShapeLayer()
        shape.lineWidth = 8
        shape.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft, .bottomLeft, .topRight, .bottomRight], cornerRadii: CGSize(width: frame.size.height / 2, height: frame.size.height / 2)).cgPath
        shape.strokeColor = UIColor.getAccentColor(fromType: .common).cgColor
        shape.fillColor = UIColor.clear.cgColor
        externalBorderLayer.mask = shape
        
        let internalBorderLayer = CALayer()
        internalBorderLayer.frame = CGRect(x: width, y: width, width: frame.size.width - (width * 2), height: frame.size.height - (width * 2))
        internalBorderLayer.borderColor = UIColor.getThemeableColor(fromNormalColor: .white).cgColor
        internalBorderLayer.borderWidth = width
        internalBorderLayer.cornerRadius = internalBorderLayer.frame.height / 2

        layer.addSublayer(externalBorderLayer)
        layer.addSublayer(internalBorderLayer)
    }
    
    func removeWrapper() {
        guard let layers = layer.sublayers, !layers.isEmpty else { return }
        fadeTransition(0.3)
        _ = layers.compactMap { layer in
            layer.removeFromSuperlayer()
        }
    }
    
    func add<T: UIView>(to view: T) {
        view.addSubview(self)
    }
    
    var roundedSize: CGFloat {
        let round = bounds.size.height / 2
        return round
    }
    
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, cornerRadius: CGFloat, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder?.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    
    var asImage: UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image(actions: { rendererContext in
            layer.render(in: rendererContext.cgContext)
        })
    }
    
    func resignFirstResponder<T: UIView>(_ object: T) {
        UIView.performWithoutAnimation {
            object.resignFirstResponder()
        }
    }
    
    func becomeFirstResponder<T: UIView>(_ object: T) {
        UIView.performWithoutAnimation {
            object.becomeFirstResponder()
        }
    }
    
    func addConstraintsWithFormat(format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewsDictionary))
    }
    
    func animated<T: UIView>(_ object: T, animations: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction, .preferredFramesPerSecond60], animations: {
            if let animations = animations {
                animations()
            }
            object.layoutIfNeeded()
        })
    }
    
    func addSubviews(_ views: [UIView]) {
        _ = views.map { addSubview($0) }
    }
}
var screenHeight: CGFloat {
    get {
        return UIScreen.main.bounds.height
    }
}
var screenWidth: CGFloat {
    get {
        return UIScreen.main.bounds.width
    }
}
var toolbarHeight: CGFloat {
    get {
        return 56
    }
}
