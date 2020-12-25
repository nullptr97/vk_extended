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
import SwiftMessages

open class ConversationsViewController: BaseViewController, ConversationsViewProtocol {
    var presenter: ConversationsPresenterProtocol?
    private let mainTable = UITableView(frame: .zero, style: .grouped)
    private var token: NotificationToken?
    var conversations = try! Realm().objects(Conversation.self).sorted(byKeyPath: "lastMessage.dateInteger", ascending: false).sorted(byKeyPath: "isImportantDialog", ascending: false).filter("isPrivateConversation = %@", false).filter("ownerId = %@", currentUserId)
    var selectedConversations = [Conversation]()
    private let swipeGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer()
        gesture.minimumNumberOfTouches = 2
        return gesture
    }()
    private var isTableEditing: Bool = false
    
    deinit {
        print("Conversations deinited")
        token?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onConnectingLongPoll), name: NSNotification.Name("onConnectingLongPoll"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onRefreshingLongPoll), name: NSNotification.Name("onRefreshingLongPoll"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onConnectedLongPoll), name: NSNotification.Name("onConnectedLongPoll"), object: nil)
        
        ConversationsRouter.initModule(self)
        presenter?.getConversations(offset: 0)
        
        navigationTitle = "Мессенджер"
        prepareTable()
        setupTable()
        setupStatusView()
        
        observeConversations()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        let addButton = IconButton(image: UIImage(named: "write_outline_28")?.withRenderingMode(.alwaysTemplate).tint(with: .getAccentColor(fromType: .common)), tintColor: .getAccentColor(fromType: .common))
        setNavigationItems(rightNavigationItems: [addButton])
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let counters = UserDefaults.standard.array(forKey: "counters") as? [Int], counters[2] > 0 else { return }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
    
    @objc func onRefreshingLongPoll() {
        DispatchQueue.main.async {
            self.navigationTitle = "Обновление"
        }
    }
    
    @objc func onConnectingLongPoll() {
        DispatchQueue.main.async {
            self.navigationTitle = "Соединение"
        }
    }
    
    @objc func onConnectedLongPoll() {
        DispatchQueue.main.async {
            self.navigationTitle = "Мессенджер"
        }
    }
    
    // Отслеживание изменений БД
    func observeConversations() {
        conversations.safeObserve({ [weak self] changes in
            guard let self = self else { return }
            
            switch changes {
            case .initial:
                self.mainTable.reloadData()
            case .update(_, let deletions, let insertions, let updates):
                self.mainTable.applyChanges(with: deletions, with: insertions, with: updates, at: 0)
            case .error(let error):
                self.event(message: error.localizedDescription, isError: true)
            }
        }) { [weak self] (token) in
            guard let self = self else { return }

            self.token = token
        }
    }
    
    // Подготовка таблицы
    func prepareTable() {
        view.addSubview(mainTable)
        mainTable.separatorStyle = .none
        mainTable.autoPinEdgesToSuperviewSafeArea(with: .top(12))
        mainTable.autoPinEdge(.bottom, to: .bottom, of: view)
        mainTable.autoPinEdge(.trailing, to: .trailing, of: view)
        mainTable.autoPinEdge(.leading, to: .leading, of: view)
        mainTable.backgroundColor = .getThemeableColor(fromNormalColor: .white)
        mainTable.setFooter()
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGestureRecognizer.minimumPressDuration = 0.25
        mainTable.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    // Настройка таблицы
    func setupTable() {
        mainTable.keyboardDismissMode = .onDrag
        mainTable.allowsMultipleSelection = true
        mainTable.allowsMultipleSelectionDuringEditing = true
        mainTable.separatorStyle = .none
        mainTable.delegate = self
        mainTable.dataSource = self
        mainTable.register(UINib(nibName: "MessageViewCell", bundle: nil), forCellReuseIdentifier: "MessageViewCell")
        swipeGesture.addTarget(self, action: #selector(onOpenPrivateConversation))
        mainTable.addGestureRecognizer(swipeGesture)
        refreshControl.add(to: mainTable) { [weak self] in
            guard let self = self else { return }
            self.reloadMessages()
        }
        nativeSearchController.setupSearchBar()
        mainTable.tableHeaderView = nativeSearchController.searchBar
    }
    
    open func setTableViewEditing(_ editing: Bool, animated: Bool) {
        mainTable.setEditing(editing, animated: true)
        isTableEditing = editing
        if !editing {
            let addButton = IconButton(image: UIImage(named: "write_outline_28")?.withRenderingMode(.alwaysTemplate).tint(with: .getAccentColor(fromType: .common)), tintColor: .getAccentColor(fromType: .common))
            setNavigationItems(leftNavigationItems: [], rightNavigationItems: [addButton])
        } else {
            let closeButton = IconButton(image: UIImage(named: "cancel_outline_28")?.withRenderingMode(.alwaysTemplate).tint(with: .getAccentColor(fromType: .common)), tintColor: .getAccentColor(fromType: .common))
            closeButton.addTarget(self, action: #selector(onEndEditing), for: .touchUpInside)
            let removeButton = IconButton(image: UIImage(named: "delete_outline_28")?.withRenderingMode(.alwaysTemplate).tint(with: .getAccentColor(fromType: .common)), tintColor: .getAccentColor(fromType: .common))
            removeButton.addTarget(self, action: #selector(onRemoveSelectedConversations), for: .touchUpInside)
            setNavigationItems(leftNavigationItems: [closeButton], rightNavigationItems: [removeButton])
        }
    }

    // Открыть приватные переписки
    @objc func onOpenPrivateConversation() {
        presenter?.onOpenPrivateConversations()
    }
    
    // Удалить выделенные переписки
    @objc func onRemoveSelectedConversations() {
        showAlert(title: "Удаление чатов", message: "Вы точно хотите удалить \(self.selectedConversations.count) \(getStringByDeclension(number: self.selectedConversations.count, arrayWords: Localization.conversationsCount))?", buttonTitles: ["Удалить", "Отмена"], highlightedButtonIndex: 1) { [weak self] (index) in
            if index == 0, let self = self {
                self.presenter?.onRemoveMultipleConversations(by: self.selectedConversations.compactMap { $0.peerId })
                self.onEndEditing()
                return
            }
        }
    }
    
    // Остановка рефрешера
    func stopRefreshControl() {
        refreshControl.endRefreshing()
    }
    
    // При обновлении страницы
    @objc func reloadMessages() {
        presenter?.getConversations(offset: 0)
    }
    
    // При отмене редактирования
    @objc func onEndEditing() {
        setTableViewEditing(false, animated: true)
        selectedConversations.removeAll()
        for cell in mainTable.cells {
            cell.setSelected(false, animated: true)
        }
        navigationTitle = "Мессенджер"
    }
    
    // Обработка долгого нажатия на диалог
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer?) {
        guard let point = gestureRecognizer?.location(in: self.mainTable), !mainTable.isEditing else { return }
        let indexPath = self.mainTable.indexPathForRow(at: point)
        if indexPath == nil {
            print("Long press on table view, not row.")
        } else if gestureRecognizer?.state == .began {
            let conversation = self.conversations[indexPath!.row]
            let messagesCount = conversation.unreadCount
            let message = messagesCount == 0 ? "Нет новых сообщений" : "\(conversation.unreadCount) \(getStringByDeclension(number: conversation.unreadCount, arrayWords: Localization.newMessagesCount))"
            self.initialActionSheet(title: conversation.interlocutor?.name ?? "---", message: message, actions: self.getActions(at: conversation, from: indexPath!))
        }
    }
}
extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageViewCell", for: indexPath) as! MessageViewCell
        cell.alternativeSetup(conversation: conversations[indexPath.row])
        cell.selectionStyle = .default
        cell.delegate = self
        return cell
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == conversations.count - 20 {
            presenter?.getConversations(offset: indexPath.row)
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isTableEditing {
            let cell = tableView.cellForRow(at: indexPath) as! MessageViewCell
            guard selectedConversations.count < 25 else {
                cell.setSelected(false, animated: true)
                event(message: "Выбрано максимальное количество", isError: true)
                return
            }
            let selectedConversation = conversations[indexPath.row]
            selectedConversations.append(selectedConversation)
            cell.setSelected(true, animated: true)
            navigationTitle = "Выбрано: \(selectedConversations.count)"
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if isTableEditing {
            let cell = tableView.cellForRow(at: indexPath) as! MessageViewCell
            for (index, conversation) in selectedConversations.enumerated() {
                if conversations[indexPath.row].peerId == conversation.peerId {
                    selectedConversations.remove(at: index)
                    cell.setSelected(false, animated: true)
                    navigationTitle = "Выбрано: \(selectedConversations.count)"
                }
            }
        }
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
        guard let presenter = self.presenter, let cell = mainTable.cellForRow(at: indexPath) as? MessageViewCell else { return [] }
        let selectConversation = MDCActionSheetAction(title: "Выбрать", image: UIImage(named: "edit_outline_28"), handler: { action in
            self.setTableViewEditing(true, animated: true)
            self.selectedConversations.append(conversation)
            cell.setSelected(true, animated: true)
            self.navigationTitle = "Выбрано: \(self.selectedConversations.count)"
        })
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
            self.dialog(title: "Удалить чат?", icon: "messages_outline_56", buttonTitle: "Удалить", secondButtonTitle: "Отмена") { (_) in
                presenter.onDeleteConversation(from: conversation.peerId)
                SwiftMessages.hide()
            } _: { (_) in
                SwiftMessages.hide()
            }
        })
        removeConversation.titleColor = .extendedBackgroundRed
        removeConversation.tintColor = .extendedBackgroundRed
        var actions: [MDCActionSheetAction]
        if conversation.unreadStatus == .unreadIn || conversation.unreadStatus == .markedUnread {
            actions = [selectConversation, setImportantStatus, readConversation, snooze, hideConversation, removeConversation]
        } else if conversation.unreadStatus != .markedUnread && !conversation.isOutgoing {
            actions = [selectConversation, setImportantStatus, /*unreadConversation*/ snooze, hideConversation, removeConversation]
        } else {
            actions = [selectConversation, setImportantStatus, snooze, hideConversation, removeConversation]
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
