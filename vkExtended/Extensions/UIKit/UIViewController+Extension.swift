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
        view.backgroundColor = .getThemeableColor(fromNormalColor: .white)
    }
    
    // Послать уведомление
    func postNotification(name: NSNotification.Name, object: Any? = nil, userInfo: [AnyHashable : Any]? = nil) {
        NotificationCenter.default.post(name: name, object: object, userInfo: userInfo)
    }
    
    // Перейти в профиль
    func pushProfile(userId: Int) {
        navigationController?.pushViewController(ProfileViewController(userId: userId), animated: true)

        setNeedsStatusBarAppearanceUpdate()
        if #available(iOS 11.0, *) {
            setNeedsUpdateOfHomeIndicatorAutoHidden()
        }
    }
    
    var fullscreenNavigationController: FullScreenNavigationController? {
        return navigationController as? FullScreenNavigationController
    }
    
    var main: DispatchQueue {
        return .main
    }
}
extension UISearchController {
    // Настройка поисковика
    func setupSearchBar() {
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([.foregroundColor: UIColor.getAccentColor(fromType: .common)], for: .normal)
        UILabel.appearance(whenContainedInInstancesOf: [UISearchBar.self]).textColor = .getThemeableColor(fromNormalColor: .darkGray)
        obscuresBackgroundDuringPresentation = false
        searchBar.backgroundImage = UIImage()
        if #available(iOS 13.0, *) {
            searchBar.searchTextField.backgroundColor = .searchColor
            searchBar.searchTextField.textColor = .getThemeableColor(fromNormalColor: .black)
            searchBar.searchTextField.font = GoogleSansFont.regular(with: 17)
            searchBar.searchTextField.setCorners(radius: 10)
        }
        searchBar.setImage(UIImage(named: "search_outline_16")?.withRenderingMode(.alwaysTemplate).tint(with: .getThemeableColor(fromNormalColor: .darkGray)), for: .search, state: .normal)
        searchBar.setImage(UIImage(named: "clear_16")?.withRenderingMode(.alwaysTemplate).tint(with: .getThemeableColor(fromNormalColor: .darkGray)), for: .clear, state: .normal)
        searchBar.setPositionAdjustment(UIOffset(horizontal: 6, vertical: 0), for: .search)
        searchBar.setPositionAdjustment(UIOffset(horizontal: -6, vertical: 0), for: .clear)
        searchBar.searchTextPositionAdjustment = UIOffset(horizontal: 4, vertical: 0)
        searchBar.directionalLayoutMargins = .init(top: 16, leading: 8, bottom: -16, trailing: 8)
    }
}

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}


// Послать уведомление
func postNotification(name: NSNotification.Name, object: Any? = nil, userInfo: [AnyHashable : Any]? = nil) {
    NotificationCenter.default.post(name: name, object: object, userInfo: userInfo)
}
