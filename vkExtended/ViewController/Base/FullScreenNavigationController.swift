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
        view.backgroundColor = .getThemeableColor(from: .white)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        definesPresentationContext = true
        edgesForExtendedLayout = []
        extendedLayoutIncludesOpaqueBars = true
        view.backgroundColor = .getThemeableColor(from: .white)
        isMotionEnabled = true
        setNavigationBarHidden(true, animated: false)
        motionNavigationTransitionType = .fade
        view.addGestureRecognizer(fullScreenPanGestureRecognizer)
        delegate = self
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
        self.fullScreenPanGestureRecognizer.isEnabled = self.viewControllers.count > 1
    }
}
extension NavigationBar {
    open override func layoutSubviews() {
        super.layoutSubviews()
        changeFrame()
    }
    
    open func changeFrame() {
        for subview in subviews {
            if NSStringFromClass(type(of: subview).self).contains("BarBackground") {
                var subViewFrame = subview.frame
                subViewFrame.origin.y -= 8
                subViewFrame.size.height = 100
                subview.frame = subViewFrame
            }
            if NSStringFromClass(type(of: subview).self).contains("BarContentView") {
                var subViewFrame = subview.frame
                subViewFrame.size.height = 52
                subview.frame = subViewFrame
            }
        }
    }
}
