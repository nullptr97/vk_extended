//
//  FriendsViewController.swift
//  Groups
//
//  Created by Ярослав Стрельников on 19.10.2020.
//

import UIKit
import PromiseKit
import MaterialComponents
import Material
import PureLayout
import DRPLoadingSpinner
import SwiftMessages

open class GroupsViewController: BaseViewController, GroupsViewProtocol {
    internal var presenter: GroupsPresenterProtocol?
    
    private let mainTable = UITableView(frame: .zero, style: .grouped)
    private var groupsViewModel = GroupViewModel.init(cells: [], footerTitle: nil)
    private lazy var footerView = FooterView(frame: CGRect(origin: .zero, size: .custom(screenWidth, 44)))
    private var searchBarIsEmpty: Bool {
        guard let text = nativeSearchController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return nativeSearchController.isActive && !searchBarIsEmpty
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationTitle = "Сообщества"
        let addButton = IconButton(image: Icon.add?.withRenderingMode(.alwaysTemplate).tint(with: .getAccentColor(fromType: .common)), tintColor: .getAccentColor(fromType: .common))
        
        setNavigationItems(rightNavigationItems: [addButton])
        
        GroupsRouter.initModule(self)
        presenter?.start(request: .getGroups)
        prepareTable()
        setupTable()
        setupStatusView()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // Подготовка таблицы
    func prepareTable() {
        view.addSubview(mainTable)
        mainTable.autoPinEdge(toSuperviewSafeArea: .top, withInset: 12)
        mainTable.autoPinEdge(.bottom, to: .bottom, of: view)
        mainTable.autoPinEdge(.trailing, to: .trailing, of: view)
        mainTable.autoPinEdge(.leading, to: .leading, of: view)
        mainTable.contentInset.bottom = 0
        mainTable.setFooter()
    }
    
    // Настройка таблицы
    func setupTable() {
        mainTable.backgroundColor = .getThemeableColor(fromNormalColor: .white)
        mainTable.keyboardDismissMode = .onDrag
        mainTable.allowsMultipleSelection = false
        mainTable.allowsMultipleSelectionDuringEditing = true
        mainTable.separatorStyle = .none
        mainTable.delegate = self
        mainTable.dataSource = self
        mainTable.register(UINib(nibName: "GroupsTableViewCell", bundle: nil), forCellReuseIdentifier: "GroupsTableViewCell")
        
        refreshControl.add(to: mainTable) { [weak self] in
            guard let self = self else { return }
            self.presenter?.start(request: .getGroups)
        }
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGestureRecognizer.minimumPressDuration = 0.25
        mainTable.addGestureRecognizer(longPressGestureRecognizer)
        nativeSearchController.setupSearchBar()
        mainTable.tableHeaderView = nativeSearchController.searchBar
        mainTable.tableFooterView = footerView
    }
    
    // Отобразить данные
    func displayData(viewModel: Groups.Model.ViewModel.ViewModelData) {
        switch viewModel {
        case .displayGroups(groupsViewModel: let groupsViewModel):
            self.groupsViewModel = groupsViewModel

            mainTable.reloadData()
            refreshControl.endRefreshing()
            mainTable.backgroundView = nil
        case .displayFooterLoader:
            break
        case .displayFooterError(message: let messageError):
            refreshControl.endRefreshing()
            mainTable.reloadData()
            break
        default:
            break
        }
    }
    
    // Обработка долгого нажатия на диалог
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer?) {
        guard let point = gestureRecognizer?.location(in: mainTable), !mainTable.isEditing, let indexPath = mainTable.indexPathForRow(at: point), gestureRecognizer?.state == .began else { return }
        
//        let friend = indexPath.section == 0 ? importantFriendViewModel.cell[indexPath.row] : friendViewModel.cell[indexPath.row]
//        initialActionSheet(title: friend.fullName, message: nil, actions: actions)
    }
    
    // При подгрузке дополнительных друзей
    @objc func getNext() {
        // presenter?.start(request: .getNextBatch)
    }
    
    @objc func onNotificationCounterChanged(notification: Notification) {
        guard let counters = notification.userInfo?["counters"] as? [Int] else { return }
    }
}
extension GroupsViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupsViewModel.cells.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupsTableViewCell", for: indexPath) as! GroupsTableViewCell
        cell.selectionStyle = .none
        cell.setup(by: groupsViewModel.cells[indexPath.row])
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return isFiltering ? 1 : 2
    }
}
extension GroupsViewController {
    // Получение доступных с другом действий
    var actions: [MDCActionSheetAction] {
        let deleteFriend = MDCActionSheetAction(title: "Удалить из друзей", image: UIImage(named: "delete_outline_28"), handler: { action in
        })
        let banFriend = MDCActionSheetAction(title: "Отправить в черный список", image: UIImage(named: "block_outline_28"), handler: { action in
        })
        banFriend.titleColor = .extendedBackgroundRed
        banFriend.tintColor = .extendedBackgroundRed
        
        return [deleteFriend, banFriend]
    }
}
