//
//  NewsfeedTabsViewController.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 25.11.2020.
//

import Foundation
import UIKit
import Material

class NewsfeedTabsViewController: TabsController {
    var cameraButton: IconButton = {
        let button = IconButton(image: UIImage(named: "camera_outline_28")?.withRenderingMode(.alwaysTemplate).tint(with: .adaptableBlue), tintColor: .adaptableBlue)
        return button
    }()
    var notificationButton: IconButton = {
        let button = IconButton(image: UIImage(named: "notification_outline_28")?.withRenderingMode(.alwaysTemplate).tint(with: .adaptableBlue), tintColor: .adaptableBlue)
        return button
    }()

    open override func prepare() {
        super.prepare()
        displayStyle = .full
        
        setupBackground()
        
        setupNavigationItem(leftViews: [cameraButton], rightViews: [notificationButton])

        tabBar.frame.size.width = navigationItem.centerViews.first?.bounds.width ?? 0
        tabBarAlignment = .top
        tabBar.backgroundColor = .getThemeableColor(fromNormalColor: .white)
        tabBar.dividerColor = .clear
        tabBar.lineHeight = 2
        tabBar.setLineColor(.getAccentColor(fromType: .common), for: .selected)
        
        navigationItem.centerViews = [tabBar]
        
        addNotificationObserver(name: .onCounterChanged, selector: #selector(onNotificationCounterChanged(notification:)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let counters = UserDefaults.standard.array(forKey: "counters") as? [Int], let firstCounter = counters.first, firstCounter > 0 else { return }
        fullscreenNavigationController?.createBadge(with: firstCounter, from: .right)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        tabBar.layer.backgroundColor = UIColor.getThemeableColor(fromNormalColor: .white).cgColor
        popupBar.layer.backgroundColor = UIColor.getThemeableColor(fromNormalColor: .white).cgColor
        view.backgroundColor = .getThemeableColor(fromNormalColor: .white)
        setupNavigationItem(leftViews: [cameraButton], rightViews: [notificationButton])
    }
    
    func setupNavigationItem(leftViews: [UIView]?, rightViews: [UIView]?) {
        if let leftViews = leftViews {
            navigationItem.leftViews = leftViews
        }
        if let rightViews = rightViews {
            navigationItem.rightViews = rightViews
        }
    }
    
    @objc func onNotificationCounterChanged(notification: Notification) {
        guard let counters = notification.userInfo?["counters"] as? [Int], let firstCounter = counters.first, firstCounter > 0 else { return }
        fullscreenNavigationController?.createBadge(with: firstCounter, from: .right)
    }
}
