//
//  ConversationsViewController.swift
//  Conversations
//
//  Created by Ярослав Стрельников on 19.10.2020.
//

import UIKit
import Alamofire
import PromiseKit
import Material
import RealmSwift
import MaterialComponents
import PureLayout
import DRPLoadingSpinner
import MBProgressHUD
import SwifterSwift

open class ConversationsViewController: BaseViewController, ConversationsViewProtocol {
    var presenter: ConversationsPresenterProtocol?
    private let mainTable = TableView(frame: .zero, style: .plain)
    private lazy var refreshControl = DRPRefreshControl()
    private var token: NotificationToken?
    private var lastContentOffset: CGFloat = 0
    private lazy var searchController = SearchBarController()
    var conversations = try! Realm().objects(Conversation.self).sorted(byKeyPath: "lastMessage.dateInteger", ascending: false).sorted(byKeyPath: "isImportantDialog", ascending: false).filter("isPrivateConversation = %@", false).filter("ownerId = %@", Constants.currentUserId)
    private let fab: MDCFloatingButton = {
        let fab = MDCFloatingButton(shape: .default)
        fab.setImage(Icon.cm.add?.withRenderingMode(.alwaysTemplate).tint(with: .adaptableWhite), for: .normal)
        fab.backgroundColor = .systemBlue
        fab.setTitleColor(.adaptableWhite, for: .normal)
        fab.isUppercaseTitle = false
        fab.setTitleFont(GoogleSansFont.semibold(with: 15), for: .normal)
        fab.setTitleColor(.getThemeableColor(from: .white), for: .normal)
        fab.setElevation(.fabResting, for: .normal)
        return fab
    }()
    private let swipeGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer()
        gesture.minimumNumberOfTouches = 2
        return gesture
    }()
    
    deinit {
        print("Conversations deinited")
        token?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onConnectingLongPoll), name: NSNotification.Name("onConnectingLongPoll"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onRefreshingLongPoll), name: NSNotification.Name("onRefreshingLongPoll"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onConnectedLongPoll), name: NSNotification.Name("onConnectedLongPoll"), object: nil)
        
        ConversationsRouter.initModule(self)
        presenter?.getConversations()
        
        title = "Мессенджер"
        prepareTable()
        setupTable()
        setupFab()
        
        observeConversations()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
    
    @objc func onRefreshingLongPoll() {
        DispatchQueue.main.async {
            self.title = "Обновление"
        }
    }
    
    @objc func onConnectingLongPoll() {
        DispatchQueue.main.async {
            self.title = "Соединение"
        }
    }
    
    @objc func onConnectedLongPoll() {
        DispatchQueue.main.async {
            self.title = "Мессенджер"
        }
    }
    
    // Отслеживание изменений БД
    func observeConversations() {
        token = conversations.observe { [weak mainTable, weak refreshControl] changes in
            guard let tableView = mainTable, let refreshControl = refreshControl else { return }
            
            switch changes {
            case .initial:
                tableView.reloadData()
                refreshControl.endRefreshing()
            case .update(_, let deletions, let insertions, let updates):
                tableView.applyChanges(with: deletions, with: insertions, with: updates, at: 0)
            case .error: break
            }
        }
    }
    
    // Настройка кнопки добавления
    func setupFab() {
        view.addSubview(fab)
        fab.autoPinEdge(.bottom, to: .bottom, of: view, withOffset: -(tabBarController?.tabBar.bounds.height ?? 0) - 16)
        fab.autoPinEdge(.trailing, to: .trailing, of: view, withOffset: -16)
    }
    
    // Подготовка таблицы
    func prepareTable() {
        view.addSubview(mainTable)
        mainTable.separatorStyle = .none
        mainTable.autoPinEdge(toSuperviewSafeArea: .top, withInset: 56)
        mainTable.autoPinEdge(.bottom, to: .bottom, of: view, withOffset: -(tabBarController?.tabBar.bounds.height ?? 0))
        mainTable.autoPinEdge(.trailing, to: .trailing, of: view)
        mainTable.autoPinEdge(.leading, to: .leading, of: view)
        mainTable.backgroundColor = .adaptableWhite
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
        swipeGesture.addTarget(self, action: #selector(onOpenPrivateConversation))
        mainTable.addGestureRecognizer(swipeGesture)
        setupSearchBar()
        refreshControl.add(to: mainTable, target: self, selector: #selector(reloadMessages))
        refreshControl.loadingSpinner.colorSequence = [.adaptableDarkGrayVK]
        refreshControl.loadingSpinner.lineWidth = 2.5
        refreshControl.loadingSpinner.rotationCycleDuration = 1
    }
    
    // Настройка поисковика
    func setupSearchBar() {
        searchController.searchBar.textField.backgroundColor = .adaptablePostColor
        searchController.searchBar.textField.textColor = .adaptableDarkGrayVK
        searchController.searchBar.textField.font = GoogleSansFont.medium(with: 18)
        searchController.searchBar.textField.setCorners(radius: 12)
        searchController.searchBar.placeholder = "Поиск диалогов"
        searchController.searchBar.placeholderColor = .adaptableDarkGrayVK
        searchController.searchBar.placeholderFont = GoogleSansFont.medium(with: 18)
        searchController.searchBar.backgroundColor = .getThemeableColor(from: .white)
        searchController.searchBar.clearButton.setImage(UIImage(named: "clear_16")?.withRenderingMode(.alwaysTemplate).tint(with: .adaptableDarkGrayVK), for: .normal)
        searchController.searchBar.searchButton.setImage(UIImage(named: "search_outline_28")?.crop(toWidth: 22, toHeight: 36)?.withRenderingMode(.alwaysTemplate).tint(with: .adaptableDarkGrayVK), for: .normal)
    }
    
    // Показать событие
    func event(message: String, isError: Bool = false) {
        MBProgressHUD.hide(for: view, animated: false)
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification.mode = .customView
        loadingNotification.label.font = GoogleSansFont.semibold(with: 14)
        loadingNotification.label.textColor = .adaptableDarkGrayVK
        loadingNotification.label.text = message
        if isError {
            loadingNotification.customView = Self.errorIndicator
            Self.errorIndicator.play()
            loadingNotification.hide(animated: true, afterDelay: 3)
        } else {
            loadingNotification.customView = Self.doneIndicator
            Self.doneIndicator.play()
            loadingNotification.hide(animated: true, afterDelay: 1)
        }
    }
    
    // Открыть приватные переписки
    @objc func onOpenPrivateConversation() {
        self.presenter?.onOpenPrivateConversations()
    }
    
    // Остановка рефрешера
    func stopRefreshControl() {
        refreshControl.endRefreshing()
    }
    
    // При обновлении страницы
    @objc func reloadMessages() {
        presenter?.getConversations()
    }
    
    // Обработка долгого нажатия на диалог
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer?) {
        guard let point = gestureRecognizer?.location(in: self.mainTable) else { return }
        let indexPath = self.mainTable.indexPathForRow(at: point)
        if indexPath == nil {
            print("Long press on table view, not row.")
        } else if gestureRecognizer?.state == .began {
            let conversation = self.conversations[indexPath!.row]
            let messagesCount = conversation.unreadCount
            let message = messagesCount == 0 ? "Нет новых сообщений" : "\(conversation.unreadCount) \(getStringByDeclension(number: conversation.unreadCount, arrayWords: Localization.instance.newMessagesCount))"
            self.initialActionSheet(title: conversation.interlocutor?.name ?? "---", message: message, actions: self.getActions(at: conversation, from: indexPath!))
        }
    }
}
extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource {
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        lastContentOffset = scrollView.contentOffset.y
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let transform = CGAffineTransform.identity
        switch scrollView.scrollDirection {
        case .up where scrollView.contentOffset.y >= lastContentOffset + 200:
            UIView.animate(.promise, duration: 0.3, delay: 0, options: .preferredFramesPerSecond60) { [weak self] in
                guard let self = self else { return }
                self.fab.transform = transform.scaledBy(x: -0.001, y: -0.001)
                self.fab.layoutIfNeeded()
            }
        case .down where scrollView.contentOffset.y < lastContentOffset - 200:
            self.fab.isHidden = false
            UIView.animate(.promise, duration: 0.3, delay: 0, options: .preferredFramesPerSecond60) { [weak self] in
                guard let self = self else { return }
                self.fab.transform = .identity
                self.fab.layoutIfNeeded()
            }
        case .down where scrollView.contentOffset.y == 0, .up where scrollView.contentOffset.y == 0:
            UIView.animate(.promise, duration: 0.3, delay: 0, options: .preferredFramesPerSecond60) { [weak self] in
                guard let self = self else { return }
                self.fab.transform = transform.scaledBy(x: -0.001, y: -0.001)
                self.fab.layoutIfNeeded()
            }
        default:
            break
        }
    }
    
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
extension ConversationsViewController: MessageViewCellDelegate {
    func didTapAvatar(cell: MessageViewCell, with peerId: Int) {
        self.presenter?.onTapPerformProfile(from: peerId)
    }
}
extension ConversationsViewController {
    // Получение доступных с диалогом действий
    func getActions(at conversation: Conversation, from indexPath: IndexPath) -> [MDCActionSheetAction] {
        guard let presenter = self.presenter else { return [] }
        let setImportantStatus = MDCActionSheetAction(title: !conversation.isImportantDialog ? "Пометить избранным" : "Убрать пометку избранного", image: UIImage(named: conversation.isImportantDialog ? "unfavorite_outline_28" : "favorite_outline_28"), handler: { action in
            self.setImportantStatus(at: conversation)
        })
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
        let hideConversation = MDCActionSheetAction(title: "Скрыть чат", image: UIImage(named: "privacy_outline_28"), handler: { action in
            let realm = try! Realm()
            UserDefaults.standard.set(true, forKey: "privateConversationFrom\(conversation.peerId)")
            realm.beginWrite()
            conversation.isPrivateConversation = true
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
        removeConversation.titleColor = .extendedRed
        removeConversation.tintColor = .extendedRed
        var actions: [MDCActionSheetAction]
        if conversation.unreadStatus == .unreadIn || conversation.unreadStatus == .markedUnread {
            actions = [setImportantStatus, readConversation, snooze, hideConversation, removeConversation]
        } else if conversation.unreadStatus != .markedUnread && !conversation.isOutgoing {
            actions = [setImportantStatus, /*unreadConversation*/ snooze, hideConversation, removeConversation]
        } else {
            actions = [setImportantStatus, snooze, hideConversation, removeConversation]
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
