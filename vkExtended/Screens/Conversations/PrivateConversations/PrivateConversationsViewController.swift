//
//  PrivateConversationsViewController.swift
//  vkExtended
//
//  Created Ярослав Стрельников on 14.11.2020.
//  Copyright © 2020 ExtendedTeam. All rights reserved.
//
import UIKit
import RealmSwift
import Material
import MaterialComponents
import DRPLoadingSpinner
import MBProgressHUD
import LocalAuthentication
import SwifterSwift

class PrivateConversationsViewController: BaseViewController, PrivateConversationsViewProtocol {

	var presenter: PrivateConversationsPresenterProtocol?
    let mainTable = TableView(frame: .zero, style: .plain)
    var conversations = try! Realm().objects(Conversation.self).sorted(byKeyPath: "lastMessage.dateInteger", ascending: false).sorted(byKeyPath: "isImportantDialog", ascending: false).filter("isPrivateConversation = %@", true).filter("ownerId = %@", currentUserId)
    private var token: NotificationToken?
    private lazy var footerView = FooterView(frame: CGRect(origin: .zero, size: .custom(screenWidth, 44)))
    private lazy var searchController = SearchBarController()
    let authQueue = DispatchQueue(label: "AuthQueue", qos: .userInteractive, attributes: .concurrent, autoreleaseFrequency: .inherit, target: .global(qos: .userInteractive))

	override func viewDidLoad() {
        super.viewDidLoad()
        PrivateConversationsRouter.initModule(self)

        title = "Приватный мессенджер"
        prepareTable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let dismissButton = IconButton(image: UIImage(named: "dismiss_24")?.withRenderingMode(.alwaysTemplate).tint(with: .getAccentColor(fromType: .common)), tintColor: .getAccentColor(fromType: .common))
        dismissButton.addTarget(self, action: #selector(self.onClosePrivateConversations), for: .touchUpInside)
        
        setNavigationItems(rightNavigationItems: [dismissButton])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        authQueue.sync {
            self.authenticationWithBiometric()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dismiss(animated: false, completion: nil)
        removeNotificationsObserver()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        preferredContentSize = CGSize(width: 0, height: UIScreen.main.bounds.height)
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        
        preferredContentSize = CGSize(width: 0, height: UIScreen.main.bounds.height)
    }

    // Отслеживание изменений БД
    func observeConversations() {
        token = conversations.observe { [weak self] changes in
            guard let self = self else { return }
            
            switch changes {
            case .initial:
                self.mainTable.reloadData()
            case .update(_, let deletions, let insertions, let updates):
                self.mainTable.applyChanges(with: deletions, with: insertions, with: updates, at: 0)
            case .error: break
            }
            self.footerView.footerTitle = self.conversations.count > 0 ? "\(self.conversations.count) \(getStringByDeclension(number: self.conversations.count, arrayWords: Localization.privateConversationsCount))" : "Нет приватных чатов"
        }
    }
    
    // Подготовка таблицы
    func prepareTable() {
        view.addSubview(mainTable)
        mainTable.separatorStyle = .none
        mainTable.autoPinEdge(toSuperviewSafeArea: .top)
        mainTable.autoPinEdge(.bottom, to: .bottom, of: view, withOffset: -(tabBarController?.tabBar.bounds.height ?? 0))
        mainTable.autoPinEdge(.trailing, to: .trailing, of: view)
        mainTable.autoPinEdge(.leading, to: .leading, of: view)
        mainTable.backgroundColor = .getThemeableColor(fromNormalColor: .white)
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGestureRecognizer.minimumPressDuration = 0.25
        mainTable.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    // Настройка таблицы
    func setupTable() {
        mainTable.keyboardDismissMode = .onDrag
        mainTable.allowsMultipleSelection = false
        mainTable.allowsMultipleSelectionDuringEditing = true
        mainTable.separatorStyle = .none
        mainTable.delegate = self
        mainTable.dataSource = self
        mainTable.register(UINib(nibName: "MessageViewCell", bundle: nil), forCellReuseIdentifier: "MessageViewCell")
        mainTable.tableHeaderView = searchController.searchBar
        mainTable.tableFooterView = footerView
        setupSearchBar()
    }
    
    // Настройка поисковика
    func setupSearchBar() {
        searchController.searchBar.textField.backgroundColor = .adaptablePostColor
        searchController.searchBar.textField.textColor = .getThemeableColor(fromNormalColor: .black)
        searchController.searchBar.textField.font = GoogleSansFont.medium(with: 17)
        searchController.searchBar.textField.setCorners(radius: 10)
        searchController.searchBar.placeholder = "Поиск"
        searchController.searchBar.placeholderColor = .getThemeableColor(fromNormalColor: .darkGray)
        searchController.searchBar.placeholderFont = GoogleSansFont.medium(with: 17)
        searchController.searchBar.backgroundColor = .getThemeableColor(fromNormalColor: .white)
        searchController.searchBar.clearButton.setImage(UIImage(named: "clear_16")?.withRenderingMode(.alwaysTemplate).tint(with: .adaptableDarkGrayVK), for: .normal)
        searchController.searchBar.searchButton.setImage(UIImage(named: "search_outline_16")?.withRenderingMode(.alwaysTemplate).tint(with: .adaptableDarkGrayVK), for: .normal)
    }
    
    // Обработка долгого нажатия на диалог
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer?) {
        guard let point = gestureRecognizer?.location(in: self.mainTable) else { return }
        guard let indexPath = self.mainTable.indexPathForRow(at: point) else { return }
        let conversation = self.conversations[indexPath.row]
        let messagesCount = conversation.unreadCount
        let message = messagesCount == 0 ? "Нет новых сообщений" : "\(conversation.unreadCount) \(getStringByDeclension(number: conversation.unreadCount, arrayWords: Localization.newMessagesCount))"
        self.initialActionSheet(title: conversation.interlocutor?.name, message: message, actions: self.getActions(at: conversation, from: indexPath))
    }
    
    // Закрыть окно приватных переписок
    @objc func onClosePrivateConversations() {
        presenter?.onClosePrivateConversations()
    }
}
extension PrivateConversationsViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageViewCell", for: indexPath) as! MessageViewCell
        cell.alternativeSetup(conversation: conversations[indexPath.row])
        cell.selectionStyle = .none
        cell.delegate = self
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
extension PrivateConversationsViewController: MessageViewCellDelegate {
    func didTapAvatar(cell: MessageViewCell, with peerId: Int) {
        self.presenter?.onTapPerformProfile(from: peerId)
    }
}
extension PrivateConversationsViewController {
    // Получение доступных с диалогом действий
    func getActions(at conversation: Conversation, from indexPath: IndexPath) -> [MDCActionSheetAction] {
        guard let presenter = self.presenter else { return [] }
        let snooze = MDCActionSheetAction(title: conversation.disabledForever ? "Включить уведомления" : "Отключить уведомления", image: UIImage(named: conversation.disabledForever ? "notification_outline_28" : "notification_disable_outline_28"), handler: { action in
            presenter.onChangeSilenceMode(from: conversation.peerId, sound: conversation.disabledForever ? 1 : 0)
        })
        let readConversation = MDCActionSheetAction(title: "Прочитать сообщения", image: UIImage(named: "view_outline_28"), handler: { action in
            presenter.onTapReadConversation(from: conversation.peerId)
        })
//        let unreadConversation = MDCActionSheetAction(title: "Пометить непрочитанным", image: UIImage(named: "view_outline_28"), handler: { [weak self] action in
//            guard let self = self else { return }
//            if UIApplication.isFirstLaunch {
//                self.settingDialog(title: "Принцип работы", message: "Эта пометка видима только Вам, и нужна лишь для накрутки значения на счетчик", okTitle: "Понятно", okHandler: {
//                    presenter.onTapUnreadConversation(from: conversation.peerId)
//                })
//            } else {
//                presenter.onTapUnreadConversation(from: conversation.peerId)
//            }
//        })
        let hideConversation = MDCActionSheetAction(title: "Показать чат", image: UIImage(named: "privacy_outline_28"), handler: { action in
            let realm = try! Realm()
            UserDefaults.standard.set(false, forKey: "privateConversationFrom\(conversation.peerId)")
            realm.beginWrite()
            conversation.isPrivateConversation = false
            try! realm.commitWrite()
            NotificationCenter.default.post(name: NSNotification.Name("privateConversations"), object: nil)
        })
        let removeConversation = MDCActionSheetAction(title: "Удалить чат", image: UIImage(named: "delete_outline_28"), handler: { [weak self] action in
            guard let self = self else { return }
            self.showAlert(title: "Удаление чата", message: "Вы точно хотите удалить чат?", buttonTitles: ["Удалить", "Отмена"], highlightedButtonIndex: 1) { (index) in
                if index == 0 {
                    presenter.onDeleteConversation(from: conversation.peerId)
                }
            }
        })
        removeConversation.titleColor = .extendedBackgroundRed
        removeConversation.tintColor = .extendedBackgroundRed
        var actions: [MDCActionSheetAction]
        if conversation.unreadStatus == .unreadIn || conversation.unreadStatus == .markedUnread {
            actions = [readConversation, snooze, hideConversation, removeConversation]
        } else if conversation.unreadStatus != .markedUnread && !conversation.isOutgoing {
            actions = [/*unreadConversation*/ snooze, hideConversation, removeConversation]
        } else {
            actions = [snooze, hideConversation, removeConversation]
        }
        
        return actions
    }
    
    func setImportantStatus(at conversation: Conversation) {
        let realm = try! Realm()
        UserDefaults.standard.set(!conversation.isImportantDialog, forKey: "importantStateFrom\(conversation.peerId)")
        realm.beginWrite()
        conversation.isImportantDialog = !conversation.isImportantDialog
        guard let interlocutor = conversation.interlocutor else { return }
        try! realm.commitWrite()
        let message = conversation.isImportantDialog ? "\(interlocutor.name) \(interlocutor.sex == 1 ? "добавлена" : "добавлен") в избранное" : "\(interlocutor.name) \(interlocutor.sex == 1 ? "удалена" : "удален") из избранного"
        self.event(message: message, isError: false)
    }
}
extension PrivateConversationsViewController {
    func authenticationWithBiometric() {
        let localAuthenticationContext = LAContext()
        localAuthenticationContext.localizedFallbackTitle = "Используйте код-пароль"
        
        var authError: NSError?
        let reasonString = "Приватные чаты"
        
        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString) { [weak self] success, evaluateError in
                guard let self = self else { return }
                self.main.async {
                    if success {
                        self.setupTable()
                        self.observeConversations()
                    } else {
                        guard let error = evaluateError else { return }
                        print(self.evaluateAuthenticationPolicyMessageForLA(errorCode: error._code))
                        self.onClosePrivateConversations()
                    }
                }
            }
        } else {
            main.async {
                guard let error = authError else { return }
                print(self.evaluateAuthenticationPolicyMessageForLA(errorCode: error.code))
                self.onClosePrivateConversations()
            }
        }
    }
    
    func evaluatePolicyFailErrorMessageForLA(errorCode: Int) -> String {
        var message = ""
        if #available(iOS 11.0, macOS 10.13, *) {
            switch errorCode {
                case LAError.biometryNotAvailable.rawValue:
                    message = "Authentication could not start because the device does not support biometric authentication."
                
                case LAError.biometryLockout.rawValue:
                    message = "Authentication could not continue because the user has been locked out of biometric authentication, due to failing authentication too many times."
                
                case LAError.biometryNotEnrolled.rawValue:
                    message = "Authentication could not start because the user has not enrolled in biometric authentication."
                
                default:
                    message = "Did not find error code on LAError object"
            }
        } else {
            switch errorCode {
                case LAError.touchIDLockout.rawValue:
                    message = "Too many failed attempts."
                
                case LAError.touchIDNotAvailable.rawValue:
                    message = "TouchID is not available on the device"
                
                case LAError.touchIDNotEnrolled.rawValue:
                    message = "TouchID is not enrolled on the device"
                
                default:
                    message = "Did not find error code on LAError object"
            }
        }
        
        return message;
    }
    
    func evaluateAuthenticationPolicyMessageForLA(errorCode: Int) -> String {
        
        var message = ""
        
        switch errorCode {
            
        case LAError.authenticationFailed.rawValue:
            message = "The user failed to provide valid credentials"
            
        case LAError.appCancel.rawValue:
            message = "Authentication was cancelled by application"
            
        case LAError.invalidContext.rawValue:
            message = "The context is invalid"
            
        case LAError.notInteractive.rawValue:
            message = "Not interactive"
            
        case LAError.passcodeNotSet.rawValue:
            message = "Passcode is not set on the device"
            
        case LAError.systemCancel.rawValue:
            message = "Authentication was cancelled by the system"
            
        case LAError.userCancel.rawValue:
            message = "The user did cancel"
            
        case LAError.userFallback.rawValue:
            message = "The user chose to use the fallback"

        default:
            message = evaluatePolicyFailErrorMessageForLA(errorCode: errorCode)
        }
        
        return message
    }
}
