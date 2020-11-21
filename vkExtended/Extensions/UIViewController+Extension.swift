//
//  ViewController+Extension.swift
//  VK Extended
//
//  Created by Ярослав Стрельников on 19.10.2020.
//

import Foundation
import UIKit
import MaterialComponents
import Lottie

public extension UIViewController {
    static var doneIndicator: AnimationView = {
        let activityIndicator = AnimationView()
        activityIndicator.animation = Animation.named("done_progress")
        activityIndicator.loopMode = .playOnce
        return activityIndicator
    }()
    
    static var errorIndicator: AnimationView = {
        let activityIndicator = AnimationView()
        activityIndicator.animation = Animation.named("error_progress")
        activityIndicator.loopMode = .playOnce
        return activityIndicator
    }()
    
    static var activityIndicator: MDCActivityIndicator = {
        let activityIndicator = MDCActivityIndicator()
        activityIndicator.cycleColors = [.adaptableDarkGrayVK]
        activityIndicator.indicatorMode = .indeterminate
        activityIndicator.radius = 16
        return activityIndicator
    }()
    
    // Создать контенер с тулбаром для контроллера
    class func makeAppBar(from viewController: UIViewController) -> MDCAppBarContainerViewController {
        return MDCAppBarContainerViewController(contentViewController: viewController)
    }
    
    // Настройка фона для контроллера
    func setupBackground() {
        view.backgroundColor = .getThemeableColor(from: .white)
    }
    
    // Послать уведомление
    func postNotification(name: NSNotification.Name, object: Any? = nil, userInfo: [AnyHashable : Any]? = nil) {
        NotificationCenter.default.post(name: name, object: object, userInfo: userInfo)
    }
}

// Послать уведомление
func postNotification(name: NSNotification.Name, object: Any? = nil, userInfo: [AnyHashable : Any]? = nil) {
    NotificationCenter.default.post(name: name, object: object, userInfo: userInfo)
}
