//
//  FullScreenNavigationController.swift
//  VKExt
//
//  Created by Ярослав Стрельников on 21.08.2020.
//

import Foundation
import UIKit
import Material
import MaterialComponents

public final class FullScreenNavigationController: NavigationController, UINavigationControllerDelegate {
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        view.backgroundColor = .getThemeableColor(fromNormalColor: .white)
    }
    
    public override func prepare() {
        super.prepare()
        delegate = self
        
        isMotionEnabled = true
        motionNavigationTransitionType = .selectBy(presenting: .fade, dismissing: .fade)
        guard let navigationBar = navigationBar as? NavigationBar else { return }
            
        navigationBar.tintColor = .getThemeableColor(fromNormalColor: .white)
        navigationBar.backgroundColor = .getThemeableColor(fromNormalColor: .white)
        navigationBar.contentEdgeInsets = .custom(6, -10, -6, -10)
        navigationBar.depthPreset = .none
        navigationBar.backIndicatorImage = UIImage(named: "Back Icon")
        navigationBar.backItem?.backButton.contentEdgeInsets = .custom(6, -12, -6, 0)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .getThemeableColor(fromNormalColor: .white)
        view.addGestureRecognizer(fullScreenPanGestureRecognizer)
    }
    
    public lazy var fullScreenPanGestureRecognizer: UIPanGestureRecognizer = {
        let gestureRecognizer = UIPanGestureRecognizer()
        
        if let cachedInteractionController = value(forKey: "_cachedInteractionController") as? NSObject {
            let selector = Selector(("handleNavigationTransition:"))
            if cachedInteractionController.responds(to: selector) {
                gestureRecognizer.addTarget(cachedInteractionController, action: selector)
            }
        }
        return gestureRecognizer
    }()
    
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        fullScreenPanGestureRecognizer.isEnabled = viewControllers.count > 1 && !(viewController is LoginViewController)
    }
}
extension NavigationBar {
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 56)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        changeFrame()
    }
    
    open func changeFrame() {
        for subview in subviews {
            if NSStringFromClass(type(of: subview).self).contains("BarContentView") {
                subview.frame.size.height = 56
                subview.tintColor = .getThemeableColor(fromNormalColor: .white)
                subview.backgroundColor = .getThemeableColor(fromNormalColor: .white)
            }
        }
    }
}

enum NavigationBarBadgeAlingment: Int {
    case left = 1
    case center = 2
    case right = 3
    case back = 4
}

extension FullScreenNavigationController {
    var fullscreenNavigationBar: NavigationBar {
        return navigationBar as! NavigationBar
    }
    
    // Создание красной точки вместо цифрового бейджа
    func createRedDot(with index: Int) {
        guard let rightFirtsView = navigationItem.rightViews.first else { return }
        for subview in rightFirtsView.subviews {
            if subview.tag == -11225841 {
                subview.removeFromSuperview()
                break
            }
        }

        let dotRaduis: CGFloat = 9
        let dotDiameter = dotRaduis * 2
        let topMargin: CGFloat = 6
        let itemWidth = rightFirtsView.width
        let xOffset = itemWidth - dotDiameter - 6
        let redDot = UIView(frame: CGRect(x: xOffset, y: topMargin, width: dotDiameter, height: dotDiameter))
        let counterLabel = UILabel()
        redDot.addSubview(counterLabel)
        
        counterLabel.autoPinEdgesToSuperviewEdges(with: .identity(2))
        counterLabel.textColor = .white
        counterLabel.font = GoogleSansFont.medium(with: 12)
        counterLabel.textAlignment = .center
        
        counterLabel.text = index.k

        redDot.tag = -11225841
        redDot.backgroundColor = .extendedBackgroundRed
        redDot.layer.cornerRadius = dotRaduis
        
        if index.digits.count > 1 {
            redDot.frame.size.width = index.k.width(with: dotDiameter - 4, font: GoogleSansFont.medium(with: 12)) + 8
            redDot.frame.origin.x = itemWidth - redDot.frame.size.width - 6
        }

        rightFirtsView.addSubview(redDot)
    }
    
    // Создание красной точки вместо цифрового бейджа
    func createBadge(with index: Int, from alingment: NavigationBarBadgeAlingment) {
        let firtsView: UIView?
        switch alingment {
        case .left:
            firtsView = navigationItem.leftViews.first
        case .center:
            firtsView = navigationItem.centerViews.first
        case .right:
            firtsView = navigationItem.rightViews.first
        case .back:
            firtsView = navigationBar.backItem?.backButton
        }
        
        guard let view = firtsView else { return }
        for subview in view.subviews {
            if subview.tag == -11225841 {
                subview.removeFromSuperview()
                break
            }
        }

        let dotRaduis: CGFloat = 9
        let dotDiameter = dotRaduis * 2
        let topMargin: CGFloat = 6
        let itemWidth = view.width
        let xOffset = itemWidth - dotDiameter - 6
        let redDot = UIView(frame: CGRect(x: xOffset, y: topMargin, width: dotDiameter, height: dotDiameter))
        let counterLabel = UILabel()
        redDot.addSubview(counterLabel)
        
        counterLabel.autoPinEdgesToSuperviewEdges(with: .identity(2))
        counterLabel.textColor = .white
        counterLabel.font = GoogleSansFont.medium(with: 12)
        counterLabel.textAlignment = .center
        
        counterLabel.text = index.k

        redDot.tag = -11225841
        redDot.backgroundColor = .extendedBackgroundRed
        redDot.layer.cornerRadius = dotRaduis
        
        if index.digits.count > 1 {
            redDot.frame.size.width = index.k.width(with: dotDiameter - 4, font: GoogleSansFont.medium(with: 12)) + 8
            redDot.frame.origin.x = itemWidth - redDot.frame.size.width - 6
        }

        view.addSubview(redDot)
    }
}
