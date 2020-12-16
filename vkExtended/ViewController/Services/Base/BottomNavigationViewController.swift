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
import LNPopupController
import Kingfisher
import AVFoundation
import SwiftMessages

let blurView: UIVisualEffectView = {
    let view = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    view.autoresizingMask = .flexibleWidth
    return view
}()

class BottomNavigationViewController: BottomNavigationController {
    static let instance: BottomNavigationViewController = BottomNavigationViewController()
    private let tabBarTitles: [String] = ["Новости", "Меню", "Мессенджер", "Друзья", "Профиль"]
    private let tabBarIcons: [UIImage?] = [UIImage(named: "news"), UIImage(named: "services_outline_28"), UIImage(named: "message_outline_28"), UIImage(named: "users_outline_28"), UIImage(named: "smile_outline_28")]
    private var tabBarControllerPreviousController: UIViewController? = nil
    private var tapCounter: Int = 0
    private var previousViewController = UIViewController()
    private weak var heightAnchor: NSLayoutConstraint?
    private let conversationServiceInstance = ConversationService.instance
    private let reachability = Reachability()
    private let mainQueue = DispatchQueue.main
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    
    let playerViewController = PlayerViewController()
    let audioViewController = AudioViewController()

    open override func prepare() {
        super.prepare()
        definesPresentationContext = true
        try! reachability?.startNotifier()
        view.backgroundColor = .getThemeableColor(fromNormalColor: .white)
        
        edgesForExtendedLayout = []
        extendedLayoutIncludesOpaqueBars = true
        delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        switch VK.sessions.default.state {
        case .destroyed, .initiated:
            navigationController?.pushViewController(LoginViewController(), animated: false)
        case .authorized:
            setup()
            setCounters()
        }
        
        addNotificationObserver(name: NSNotification.Name("ReachabilityChangedNotification"), selector: #selector(onReachabilityStatusChanged(notification:)))
        addNotificationObserver(name: .onLogout, selector: #selector(onLogout(notification:)))
        addNotificationObserver(name: .onLogin, selector: #selector(onLogin(notification:)))
        addNotificationObserver(name: .onCounterChanged, selector: #selector(onBadgeCountChanged(notification:)))
        addNotificationObserver(name: UIApplication.didBecomeActiveNotification, selector: #selector(onActiveMode))
        addNotificationObserver(name: UIApplication.willResignActiveNotification, selector: #selector(onBackgroundMode))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeNotificationsObserver()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        tabBar.layer.backgroundColor = UIColor.getThemeableColor(fromNormalColor: .white).cgColor
        popupBar.layer.backgroundColor = UIColor.getThemeableColor(fromNormalColor: .white).cgColor
        view.backgroundColor = .getThemeableColor(fromNormalColor: .white)
        setupPlayer(from: AudioService.instance.player.state, from: playerViewController)
    }
    
    override func remoteControlReceived(with event: UIEvent?) {
        if let event = event {
             AudioService.instance.player.remoteControlReceived(with: event)
        }
    }
    
    override var bottomDockingViewForPopupBar: UIView? {
        return tabBar
    }
    
    func registerSettingsBundle() {
        let appDefaults = [String: AnyObject]()
        UserDefaults.standard.register(defaults: appDefaults)
    }
    
    @objc func defaultsChanges() {
        if UserDefaults.standard.bool(forKey: "alternateIcon") {
            guard UIApplication.shared.supportsAlternateIcons else { return }
            UIApplication.shared.setAlternateIconName("extended2", completionHandler: { (error) in
                if let error = error {
                    print("App icon failed to change due to \(error.localizedDescription)")
                } else {
                    print("App icon changed successfully")
                }
            })
        } else {
            guard UIApplication.shared.supportsAlternateIcons else { return }
            UIApplication.shared.setAlternateIconName("extended1", completionHandler: { (error) in
                if let error = error {
                    print("App icon failed to change due to \(error.localizedDescription)")
                } else {
                    print("App icon changed successfully")
                }
            })
        }
    }
    
    // Настройка плеера
    func setupPlayer() {
        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        popupBar.titleTextAttributes = [.font: GoogleSansFont.medium(with: 15), .foregroundColor: UIColor.getThemeableColor(fromNormalColor: .black), .paragraphStyle: paragraphStyle]
        popupBar.subtitleTextAttributes = [.font: GoogleSansFont.medium(with: 13), .foregroundColor: UIColor.adaptableDarkGrayVK, .paragraphStyle: paragraphStyle]
        popupBar.backgroundStyle = .regular
        popupBar.tintColor = .getAccentColor(fromType: .common)
        popupBar.backgroundColor = .getThemeableColor(fromNormalColor: .white)
        popupBar.layer.backgroundColor = UIColor.getThemeableColor(fromNormalColor: .white).cgColor
        popupBar.barTintColor = .getThemeableColor(fromNormalColor: .white)
        
        popupInteractionStyle = .drag
        popupBar.barStyle = .compact
        popupBar.dividerAlignment = .top
        popupBar.dividerThickness = 0.4
        popupBar.dividerColor = .getThemeableColor(fromNormalColor: .lightGray)
        popupBar.progressViewStyle = .top
    }
    
    // Настройка контроллера
    func setup() {
        prepareControllers()
        prepareTabBar()
        setCounters()
        setupPlayer()
        AudioService.instance.player.delegate = self
        
        guard let viewControllers = viewControllers, viewControllers.count >= UserDefaults.standard.integer(forKey: "savedIndexViewController") else { return }
        selectedIndex = UserDefaults.standard.integer(forKey: "savedIndexViewController")
    }
    
    // Добавление защитного блюра
    func addBlur() {
        let messageView: MessageView = MessageView.viewFromNib(layout: .centeredView)
        messageView.configureBackgroundView(width: 0)
        messageView.configureContent(title: nil, body: nil, iconImage: nil, iconText: nil, buttonImage: nil, buttonTitle: nil, buttonTapHandler: nil)
        messageView.backgroundView.backgroundColor = .clear
        messageView.backgroundView.layer.cornerRadius = 10
        var config = SwiftMessages.defaultConfig
        config.presentationStyle = .center
        config.duration = .forever
        config.dimMode = .blur(style: .regular, alpha: 1, interactive: true)
        config.presentationContext  = .window(windowLevel: UIWindow.Level.statusBar)
        SwiftMessages.show(config: config, view: messageView)
    }
    
    // Удаление защитного блюра
    func removeBlur() {
        SwiftMessages.hide()
    }
    
    // При переходе в фоновый режим
    @objc func onBackgroundMode() {
        //addBlur()
    }
    
    // При переходе в активный режим
    @objc func onActiveMode() {
        //removeBlur()
    }
    
    @objc func onReachabilityStatusChanged(notification: Notification) {
        guard let reachability = notification.object as? Reachability else { return }
        mainQueue.async {
            switch reachability.currentReachabilityStatus {
            case .notReachable:
                UserDefaults.standard.setValue(false, forKey: "isReachable")
                (((self.viewControllers?[1] as? FullScreenNavigationController)?.viewControllers.first as? ConversationsViewController))?.title = "Ожидание соединения"
            case .reachableViaWiFi, .reachableViaWWAN:
                UserDefaults.standard.setValue(true, forKey: "isReachable")
            }
        }
    }
    
    @objc func onLogout(notification: Notification) {
        
    }
    
    @objc func onLogin(notification: Notification) {
        setup()
    }
    
    // Настройка контроллеров таббара
    fileprivate func prepareControllers() {
        viewControllers = [
            FullScreenNavigationController(rootViewController: NewsfeedTabsViewController(viewControllers: [NewsfeedViewController(), SuggestionsViewController()])),
            FullScreenNavigationController(rootViewController: ServicesMenuViewController()),
            FullScreenNavigationController(rootViewController: ConversationsViewController()),
            FullScreenNavigationController(rootViewController: FriendsViewController()),
            FullScreenNavigationController(rootViewController: ProfileViewController(userId: currentUserId))
        ]
    }
    
    // Настройка таббара
    fileprivate func prepareTabBar() {
        for (index, tabBarItem) in (tabBar.items ?? []).enumerated() {
            tabBarItem.title = tabBarTitles[index]
            tabBarItem.setTitleTextAttributes([.font: GoogleSansFont.semibold(with: 12)], for: .normal)
            tabBarItem.image = tabBarIcons[index]
        }

        isSwipeEnabled = false
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        UITabBarItem.appearance().setBadgeTextAttributes([.font: GoogleSansFont.medium(with: 12), .paragraphStyle: style], for: .normal)
        UITabBarItem.appearance().badgeColor = .extendedBackgroundRed
        tabBar.dividerThickness = 0.4
        tabBar.dividerAlignment = .top
        tabBar.dividerColor = .getThemeableColor(fromNormalColor: .lightGray)
        tabBar.isTranslucent = true
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
        tabBar.barTintColor = .clear
        tabBar.backgroundColor = UIColor.getThemeableColor(fromNormalColor: .white)
        tabBar.layer.backgroundColor = UIColor.getThemeableColor(fromNormalColor: .white).cgColor
        tabBar.clipsToBounds = true
        tabBar.tintColor = .getAccentColor(fromType: .common)
        tabBar.heightPreset = .custom(52)
    }
    
    // Установка значения бейджика
    fileprivate func setBadgeCounter(at indexes: [Int], values: [Int]) {
        DispatchQueue.main.async {
            for index in indexes {
                let value = values[index] != 0 ? "\(values[index])" : nil
                if index == 2 {
                    self.tabBar.items?[index].badgeValue = value
                    self.tabBar.items?[index].badgeColor = .extendedBackgroundRed
                } else {
                    if value != nil && value != "0" {
                        self.createRedDot(at: index)
                    }
                }
            }
        }
    }
    
    // Установить значения счетчиков
    func setCounters() {
        Request.dataRequest(method: ApiMethod.method(from: .account, with: ApiMethod.Account.getCounters), parameters: [:]).done { response in
            switch response {
            case .success(let data):
                let newsTabCount = (JSON(data)["notifications"].int ?? 0) + (JSON(data)["events"].int ?? 0) + (JSON(data)["gifts"].int ?? 0)
                let recommendationsTabCount = (JSON(data)["friends_recommendations"].int ?? 0) + (JSON(data)["groups"].int ?? 0)
                let messagesTabCount = JSON(data)["messages"].int ?? 0
                let friendsTabCount = JSON(data)["friends"].int ?? 0
                let accountTabCount = (JSON(data)["photos"].int ?? 0) + (JSON(data)["videos"].int ?? 0)
                let counters = [newsTabCount, recommendationsTabCount, messagesTabCount, friendsTabCount, accountTabCount]
                let userInfo: [AnyHashable: Any]? = ["counters": counters]
                UserDefaults.standard.set(counters, forKey: "counters")
                NotificationCenter.default.post(name: .onCounterChanged, object: nil, userInfo: userInfo)
            case .error(let error):
                let userInfo: [AnyHashable: Any]? = ["counters": [0, 0, 0, 0, 0]]
                UserDefaults.standard.set([0, 0, 0, 0, 0], forKey: "counters")
                NotificationCenter.default.post(name: .onCounterChanged, object: nil, userInfo: userInfo)
                print(error.toApi()?.message ?? "")
            }
            
        }.catch { error in
            let userInfo: [AnyHashable: Any]? = ["counters": [0, 0, 0, 0, 0]]
            UserDefaults.standard.set([0, 0, 0, 0, 0], forKey: "counters")
            NotificationCenter.default.post(name: .onCounterChanged, object: nil, userInfo: userInfo)
            print(error.toVK().localizedDescription)
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
        UserDefaults.standard.set(selectedIndex, forKey: "savedIndexViewController")
        UserDefaults.standard.synchronize()
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
        let topMargin: CGFloat = AudioService.instance.player.state == .playing ? 44 : 4
        let itemsCount = CGFloat(tabBar.items!.count)
        let halfItemWidth = UIScreen.main.bounds.width / (itemsCount * 2)
        let xOffset = halfItemWidth * CGFloat(index * 2 + 1)
        let imageHalfWidth: CGFloat = (tabBar.items![index]).selectedImage!.size.width / 2
        let redDot = UIView(frame: CGRect(x: xOffset + imageHalfWidth - 3, y: topMargin, width: dotDiameter, height: dotDiameter))

        redDot.tag = -11225841 + index
        redDot.backgroundColor = .extendedBackgroundRed
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
        playView.backgroundColor = .getAccentColor(fromType: .common)
        playView.layer.cornerRadius = dotRaduis

        tabBar.addSubview(playView)
    }
}
extension BottomNavigationViewController: AudioPlayerDelegate {
    func audioPlayer(_ audioPlayer: AudioPlayer, didChangeStateFrom from: AudioPlayerState,
                     to state: AudioPlayerState) {
        playerViewController.popupContentView.backgroundStyle = .regular
        if state == .playing || state == .paused || state == .buffering || state == .waitingForConnection {
            presentPopupBar(withContentViewController: playerViewController, animated: true, completion: nil)
        } else {
            dismissPopupBar(animated: true, completion: nil)
        }
        setupPlayer(from: state, from: playerViewController)
    }

    func audioPlayer(_ audioPlayer: AudioPlayer, shouldStartPlaying item: AudioItem) -> Bool { return true }

    func audioPlayer(_ audioPlayer: AudioPlayer, willStartPlaying item: AudioItem) {
        playerViewController.popupItem.title = item.model.title
        playerViewController.popupItem.subtitle = item.model.artist
        
        playerViewController.titleLabel.text = item.model.title
        playerViewController.artistLabel.text = item.model.artist
        playerViewController.blurredArtworkImageView.contentMode = .scaleAspectFill
                
        if let url = URL(string: item.model.album.imageUrl) {
            KingfisherManager.shared.retrieveImage(with: url) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let value):
                    self.playerViewController.popupItem.image = value.image
                    self.playerViewController.artworkImageView.contentMode = .scaleAspectFit
                    self.playerViewController.artworkImageView.image = value.image
                    self.playerViewController.blurredArtworkImageView.blurred(withStyle: .regular).image = value.image
                case .failure(let error):
                    self.playerViewController.artworkImageView.contentMode = .center
                    self.playerViewController.artworkImageView.image = UIImage(named: "music_note_80")
                    self.playerViewController.blurredArtworkImageView.image = nil
                    print(error.errorDescription ?? "")
                }
            }
        } else {
            self.playerViewController.artworkImageView.contentMode = .center
            self.playerViewController.artworkImageView.image = UIImage(named: "music_note_80")
            self.playerViewController.blurredArtworkImageView.image = nil
        }
        
         postNotification(name: .onPlayerStateChanged)
    }

    func audioPlayer(_ audioPlayer: AudioPlayer, didUpdateProgressionTo time: TimeInterval, percentageRead: Float) {
        playerViewController.popupItem.progress = percentageRead / 100
        playerViewController.progressSlider.newValue = percentageRead / 100
        playerViewController.progressSlider.value = percentageRead / 100
    }

    func audioPlayer(_ audioPlayer: AudioPlayer, didFindDuration duration: TimeInterval, for item: AudioItem) {}

    func audioPlayer(_ audioPlayer: AudioPlayer, didUpdateEmptyMetadataOn item: AudioItem, withData data: Metadata) {}

    func audioPlayer(_ audioPlayer: AudioPlayer, didLoad range: TimeRange, for item: AudioItem) {
        playerViewController.progressSlider.bufferEndValue = item.model.duration > 0 ? Float(range.latest / item.model.duration.double).double : 0.double
    }
    
    func setupPlayer(from state: AudioPlayerState, from controller: UIViewController) {
        switch state {
        case .buffering:
            controller.popupItem.trailingBarButtonItems = [UIBarButtonItem(image: UIImage(named: "cancel_outline_28")?.crop(toWidth: 20, toHeight: 20)?.withRenderingMode(.alwaysTemplate).tint(with: .adaptableDarkGrayVK), style: .plain, target: self, action: #selector(stopTrack))]
            controller.popupItem.leadingBarButtonItems = [UIBarButtonItem(image: UIImage(named: "play_48")?.crop(toWidth: 20, toHeight: 20)?.withRenderingMode(.alwaysTemplate).tint(with: .getAccentColor(fromType: .common)), style: .plain, target: self, action: #selector(resumeTrack))]
        case .playing:
            playerViewController.albumArtworkWidth.constant = screenWidth - 64
            playerViewController.albumArtworkHeight.constant = screenWidth - 64
            playerViewController.sliderTopPaddingConstraint.constant = 32
            
            UIView.animate(.promise, duration: 0.3) {
                self.playerViewController.view.layoutIfNeeded()
            }
            controller.popupItem.trailingBarButtonItems = [UIBarButtonItem(image: UIImage(named: "skip_next_24")?.withRenderingMode(.alwaysTemplate).tint(with: .getAccentColor(fromType: .common)), style: .plain, target: self, action: #selector(nextTrack))]
            controller.popupItem.leadingBarButtonItems = [UIBarButtonItem(image: UIImage(named: "pause_48")?.crop(toWidth: 20, toHeight: 20)?.withRenderingMode(.alwaysTemplate).tint(with: .getAccentColor(fromType: .common)), style: .plain, target: self, action: #selector(pauseTrack))]
            playerViewController.playingButton.setImage(UIImage(named: "pause_48")?.withRenderingMode(.alwaysTemplate).tint(with: .getThemeableColor(fromNormalColor: .black)), for: .normal)
        case .paused:
            playerViewController.albumArtworkWidth.constant = screenWidth - 128
            playerViewController.albumArtworkHeight.constant = screenWidth - 128
            playerViewController.sliderTopPaddingConstraint.constant = 96
            
            UIView.animate(.promise, duration: 0.3) {
                self.playerViewController.view.layoutIfNeeded()
            }
            controller.popupItem.trailingBarButtonItems = [UIBarButtonItem(image: UIImage(named: "cancel_outline_28")?.crop(toWidth: 20, toHeight: 20)?.withRenderingMode(.alwaysTemplate).tint(with: .adaptableDarkGrayVK), style: .plain, target: self, action: #selector(stopTrack))]
            controller.popupItem.leadingBarButtonItems = [UIBarButtonItem(image: UIImage(named: "play_48")?.crop(toWidth: 20, toHeight: 20)?.withRenderingMode(.alwaysTemplate).tint(with: .getAccentColor(fromType: .common)), style: .plain, target: self, action: #selector(resumeTrack))]
            playerViewController.playingButton.setImage(UIImage(named: "play_48")?.withRenderingMode(.alwaysTemplate).tint(with: .getThemeableColor(fromNormalColor: .black)), for: .normal)
        case .stopped:
            controller.popupItem.trailingBarButtonItems = [UIBarButtonItem(image: UIImage(named: "cancel_outline_28")?.crop(toWidth: 20, toHeight: 20)?.withRenderingMode(.alwaysTemplate).tint(with: .adaptableDarkGrayVK), style: .plain, target: self, action: #selector(stopTrack))]
            controller.popupItem.leadingBarButtonItems = [UIBarButtonItem(image: UIImage(named: "play_48")?.crop(toWidth: 20, toHeight: 20)?.withRenderingMode(.alwaysTemplate).tint(with: .getAccentColor(fromType: .common)), style: .plain, target: self, action: #selector(resumeTrack))]
        case .waitingForConnection:
            controller.popupItem.trailingBarButtonItems = [UIBarButtonItem(image: UIImage(named: "cancel_outline_28")?.crop(toWidth: 20, toHeight: 20)?.withRenderingMode(.alwaysTemplate).tint(with: .adaptableDarkGrayVK), style: .plain, target: self, action: #selector(stopTrack))]
            controller.popupItem.leadingBarButtonItems = [UIBarButtonItem(image: UIImage(named: "play_48")?.crop(toWidth: 20, toHeight: 20)?.withRenderingMode(.alwaysTemplate).tint(with: .getAccentColor(fromType: .common)), style: .plain, target: self, action: #selector(resumeTrack))]
        case .failed(_):
            controller.popupItem.trailingBarButtonItems = [UIBarButtonItem(image: UIImage(named: "cancel_outline_28")?.crop(toWidth: 20, toHeight: 20)?.withRenderingMode(.alwaysTemplate).tint(with: .adaptableDarkGrayVK), style: .plain, target: self, action: #selector(stopTrack))]
            controller.popupItem.leadingBarButtonItems = [UIBarButtonItem(image: UIImage(named: "play_48")?.crop(toWidth: 20, toHeight: 20)?.withRenderingMode(.alwaysTemplate).tint(with: .getAccentColor(fromType: .common)), style: .plain, target: self, action: #selector(resumeTrack))]
        }
    }
    
    @objc func pauseTrack() {
        AudioService.instance.action(.pause)
    }
    
    @objc func resumeTrack() {
        AudioService.instance.action(.resume)
    }
    
    @objc func nextTrack() {
        AudioService.instance.action(.next)
    }
    
    @objc func stopTrack() {
        AudioService.instance.action(.stop)
        dismissPopupBar(animated: true, completion: nil)
    }
}
