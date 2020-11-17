//
//  TabBarStartController.swift
//  VK Tosters
//
//  Created by programmist_np on 30/01/2020.
//  Copyright © 2020 programmist_np. All rights reserved.
//

import UIKit
import MaterialComponents
import Material
import SwiftyJSON
import MBProgressHUD

let blurView: UIVisualEffectView = {
    let view = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    view.autoresizingMask = .flexibleWidth
    return view
}()

class BottomNavigationViewController: BottomNavigationController {
    static let instance: BottomNavigationViewController = BottomNavigationViewController()
    let tabBarTitles: [String] = ["Меню", "Мессенджер", "Друзья", "Профиль", "Профиль"]
    let tabBarIcons: [UIImage?] = [UIImage(named: "compass_outline_28"), UIImage(named: "message_outline_28"), UIImage(named: "users_outline_28"), UIImage(named: "smile_outline_28"), UIImage(named: "smile_outline_28")]
    private var tabBarControllerPreviousController: UIViewController? = nil
    private var tapCounter: Int = 0
    private var previousViewController = UIViewController()
    private weak var heightAnchor: NSLayoutConstraint?
    private let center = NotificationCenter.default
    private let conversationServiceInstance = ConversationService.instance
    private let reachability = Reachability()
    private let mainQueue = DispatchQueue.main
    open var transitionDelegate = MDCBottomSheetTransitionController()

    open override func prepare() {
        super.prepare()
        definesPresentationContext = true
        try! reachability?.startNotifier()
        view.backgroundColor = .getThemeableColor(from: .white)
        motionTransitionType = .fade
        prepareControllers()
        prepareTabBar()
        edgesForExtendedLayout = []
        extendedLayoutIncludesOpaqueBars = true
        delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(onReachabilityStatusChanged(notification:)), name: NSNotification.Name("ReachabilityChangedNotification"), object: reachability)
        NotificationCenter.default.addObserver(self, selector: #selector(onLogout(notification:)), name: .onLogout, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addNotificationObserver(name: UIApplication.willResignActiveNotification, selector: #selector(onBackgroundMode))
        addNotificationObserver(name: UIApplication.didBecomeActiveNotification, selector: #selector(onActiveMode))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeNotificationsObserver()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        tabBar.layer.backgroundColor = UIColor.getThemeableColor(from: .white)/*.withAlphaComponent(0.82)*/.cgColor
        view.backgroundColor = .getThemeableColor(from: .white)
    }
    
    override func remoteControlReceived(with event: UIEvent?) {
//        if let event = event {
//            // VKAudioService.instance.player.remoteControlReceived(with: event)
//        }
    }
    
    // Добавление защитного блюра
    func addBlur() {
        let blurScreenshot = UIImageView(image: view.screenshot?.blurImage(with: 10))
        blurScreenshot.backgroundColor = .clear
        blurScreenshot.frame = CGRect(origin: CGPoint(x: 0, y: -32), size: CGSize(width: Screen.bounds.width + 32, height: Screen.bounds.height + 32))
        blurScreenshot.tag = 1241
        UIView.transition(with: view, duration: 0.2, options: [.transitionCrossDissolve, .curveEaseIn], animations: {
            self.view.addSubview(blurScreenshot)
            self.view.bringSubviewToFront(blurScreenshot)
        }, completion: nil)
    }
    
    // Удаление защитного блюра
    func removeBlur() {
        let blurScreenshot = view.viewWithTag(1241) as? UIImageView
        UIView.transition(with: view, duration: 0.2, options: [.transitionCrossDissolve, .curveEaseOut], animations: {
             blurScreenshot?.removeFromSuperview()
        }, completion: nil)
    }
    
    // При переходе в фоновый режим
    @objc func onBackgroundMode() {
        addBlur()
    }
    
    // При переходе в активный режим
    @objc func onActiveMode() {
        removeBlur()
    }
    
    @objc func onReachabilityStatusChanged(notification: Notification) {
        guard let reachability = notification.object as? Reachability else { return }
        MBProgressHUD.hide(for: view, animated: false)
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification.mode = .customView
        loadingNotification.customView = Self.activityIndicator
        loadingNotification.label.font = GoogleSansFont.semibold(with: 14)
        loadingNotification.label.textColor = .adaptableDarkGrayVK
        Self.activityIndicator.startAnimating()
        mainQueue.async {
            switch reachability.currentReachabilityStatus {
            case .notReachable:
                UserDefaults.standard.setValue(false, forKey: "isReachable")
                (((self.viewControllers?[0] as? FullScreenNavigationController)?.viewControllers.first as? MDCAppBarContainerViewController)?.contentViewController as? ConversationsViewController)?.title = "Ожидание соединения"
                loadingNotification.label.text = "Ожидание соединения"
                UIView.animate(.promise, duration: 0.3, delay: 0, options: [.preferredFramesPerSecond60]) {
                    loadingNotification.layoutIfNeeded()
                }
                self.mainQueue.asyncAfter(deadline: .now() + 3) {
                    loadingNotification.customView = Self.errorIndicator
                    Self.errorIndicator.play()
                    loadingNotification.hide(animated: true, afterDelay: 3)
                }
            case .reachableViaWiFi, .reachableViaWWAN:
                UserDefaults.standard.setValue(true, forKey: "isReachable")
                loadingNotification.label.text = "Подключено"
                UIView.animate(.promise, duration: 0.3, delay: 0, options: [.preferredFramesPerSecond60]) {
                    loadingNotification.layoutIfNeeded()
                }
                loadingNotification.customView = Self.doneIndicator
                Self.doneIndicator.play()
                loadingNotification.hide(animated: true, afterDelay: 1)
            }
        }
    }
    
    @objc func onLogout(notification: Notification) {
        
    }
    
    // Настройка контроллеров таббара
    fileprivate func prepareControllers() {
        viewControllers = [
            FullScreenNavigationController(rootViewController: MenuViewController()),
            FullScreenNavigationController(rootViewController: ConversationsViewController()),
            FullScreenNavigationController(rootViewController: FriendsViewController()),
            FullScreenNavigationController(rootViewController: ProfileViewController(userId: Constants.currentUserId))
//            FullScreenNavigationController(rootViewController: NewsFeedTabsController(viewControllers: [NewsfeedViewController(), SuggestionsViewController()])),
//            FullScreenNavigationController(rootViewController: RecomendationsViewController()),
//            FullScreenNavigationController(rootViewController: ConversationsViewController()),
//            FullScreenNavigationController(rootViewController: FriendsViewController()),
//            FullScreenNavigationController(rootViewController: ProfileViewController())
        ]
    }
    
    // Настройка таббара
    fileprivate func prepareTabBar() {
        for (index, tabBarItem) in (tabBar.items ?? []).enumerated() {
            tabBarItem.title = tabBarTitles[index]
            tabBarItem.setTitleTextAttributes([.font: GoogleSansFont.medium(with: 12)], for: .normal)
            tabBarItem.image = tabBarIcons[index]
        }

        isSwipeEnabled = false
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        UITabBarItem.appearance().badgeColor = .systemRed
        tabBar.depthPreset = .depth4
        tabBar.dividerThickness = 0.0
        tabBar.isTranslucent = true
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
        tabBar.barTintColor = .clear
        tabBar.backgroundColor = UIColor.getThemeableColor(from: .white)//.withAlphaComponent(0.0)
        tabBar.layer.backgroundColor = UIColor.getThemeableColor(from: .white)/*.withAlphaComponent(0.82)*/.cgColor
        tabBar.clipsToBounds = false
        tabBar.tintColor = .systemBlue
        tabBar.heightPreset = .custom(52)
    }
    
    // Установка значения бейджика
    fileprivate func setBadgeCounter(at indexes: [Int], values: [Int]) {
        DispatchQueue.main.async {
            for index in indexes {
                let value = values[index] != 0 ? "\(values[index])" : nil
                if index == 2 {
                    self.tabBar.items?[index].badgeValue = value
                    self.tabBar.items?[index].badgeColor = .systemRed
                } else {
                    if value != nil && value != "0" {
                        self.createRedDot(at: index)
                    }
                }
            }
        }
    }
    
    // Уведомление о изменении значения бейджа
    @objc func onBadgeCountChanged(notification: Notification) {
        guard let counters = notification.userInfo?["counters"] as? [Int] else { return }
        setBadgeCounter(at: [0, 1, 2, 3, 4], values: counters)
    }
}
extension BottomNavigationViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        tabBarControllerPreviousController = viewController
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        tapCounter += 1
        var hasTappedTwiceOnOneTab = false
        if previousViewController == viewController {
            hasTappedTwiceOnOneTab = true
        }
        previousViewController = viewController
        if tapCounter == 2 && hasTappedTwiceOnOneTab {
            tapCounter = 0
            switch selectedIndex {
            case 2:
                VK.sessions.default.logOut()
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(LoginViewController(), animated: true)
                }
            default:
                break
            }
            return false
        } else if tapCounter == 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.tapCounter = 0
            }
            return true
        }
        return true
    }
}
extension BottomNavigationController {
    
    // Создание красной точки вместо цифрового бейджа
    func createRedDot(at index: Int) {
        for subview in tabBar.subviews {
            if subview.tag == -11225841 + index {
                subview.removeFromSuperview()
                break
            }
        }

        let dotRaduis: CGFloat = 3
        let dotDiameter = dotRaduis * 2
        let topMargin: CGFloat = 4
        let itemsCount = CGFloat(tabBar.items!.count)
        let halfItemWidth = UIScreen.main.bounds.width / (itemsCount * 2)
        let xOffset = halfItemWidth * CGFloat(index * 2 + 1)
        let imageHalfWidth: CGFloat = (tabBar.items![index]).selectedImage!.size.width / 2
        let redDot = UIView(frame: CGRect(x: xOffset + imageHalfWidth - 3, y: topMargin, width: dotDiameter, height: dotDiameter))

        redDot.tag = -11225841 + index
        redDot.backgroundColor = .systemRed
        redDot.layer.cornerRadius = dotRaduis

        tabBar.addSubview(redDot)
    }
    
    
    // Бейджик о работе плеера
    func createPlayingImage(at index: Int) {
        for subview in tabBar.subviews {
            if subview.tag == -11225842 + index {
                subview.removeFromSuperview()
                break
            }
        }

        let dotRaduis: CGFloat = 8
        let dotDiameter = dotRaduis * 2
        let topMargin: CGFloat = 2
        let itemsCount = CGFloat(tabBar.items!.count)
        let halfItemWidth = UIScreen.main.bounds.width / (itemsCount * 2)
        let xOffset = halfItemWidth * CGFloat(index * 2 + 1)
        let imageHalfWidth: CGFloat = (tabBar.items![index]).selectedImage!.size.width / 2
        let playView = UIView(frame: CGRect(x: xOffset + imageHalfWidth - 3, y: topMargin, width: dotDiameter, height: dotDiameter))
        let playImage = UIImageView(image: UIImage(named: "play_16")?.withRenderingMode(.alwaysTemplate).tint(with: .white))
        
        playView.addSubview(playImage)
        playImage.frame = playView.bounds

        playView.tag = -11225842 + index
        playImage.tag = -0x291
        playView.backgroundColor = .systemBlue
        playView.layer.cornerRadius = dotRaduis

        tabBar.addSubview(playView)
    }
}
