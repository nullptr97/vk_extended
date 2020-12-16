//
//  FriendsViewController.swift
//  Friends
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

open class FriendsViewController: BaseViewController, FriendsViewProtocol {
    internal var presenter: FriendsPresenterProtocol?
    
    private let mainTable = UITableView(frame: .zero, style: .grouped)
    private var friendViewModel = FriendViewModel.init(cell: [], footerTitle: nil, count: 0)
    private var importantFriendViewModel = FriendViewModel.init(cell: [], footerTitle: nil, count: 0)
    private var searchedFriendViewModel = FriendViewModel.init(cell: [], footerTitle: nil, count: 0)
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
        
        navigationTitle = "Друзья"
        let listButton = IconButton(image: UIImage(named: "list_outline_28")?.withRenderingMode(.alwaysTemplate).tint(with: .getAccentColor(fromType: .common)), tintColor: .getAccentColor(fromType: .common))
        
        setNavigationItems(rightNavigationItems: [listButton])
        
        FriendsRouter.initModule(self)
        presenter?.start(request: .getFriend())
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
        mainTable.autoPinEdge(toSuperviewSafeArea: .top, withInset: 16)
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
        mainTable.register(UINib(nibName: "FriendsTableViewCell", bundle: nil), forCellReuseIdentifier: "FriendsTableViewCell")
        
        refreshControl.add(to: mainTable) { [weak self] in
            guard let self = self else { return }
            self.presenter?.start(request: .getFriend())
        }
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGestureRecognizer.minimumPressDuration = 0.25
        mainTable.addGestureRecognizer(longPressGestureRecognizer)
        nativeSearchController.setupSearchBar()
        mainTable.tableHeaderView = nativeSearchController.searchBar
        mainTable.tableFooterView = footerView
        nativeSearchController.searchBar.delegate = self
        nativeSearchController.searchResultsUpdater = self
    }
    
    // Отобразить данные
    func displayData(viewModel: FriendModel.ViewModel.ViewModelData) {
        switch viewModel {
        case .displayAllFriend(importantFriendViewModel: let importantFriendViewModel, friendViewModel: let friendsViewModel):
            self.friendViewModel = friendsViewModel
            self.importantFriendViewModel = importantFriendViewModel

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
        
        let friend = indexPath.section == 0 ? importantFriendViewModel.cell[indexPath.row] : friendViewModel.cell[indexPath.row]
        initialActionSheet(title: friend.fullName, message: nil, actions: actions)
    }
    
    // При подгрузке дополнительных друзей
    @objc func getNext() {
        // presenter?.start(request: .getNextBatch)
    }
    
    @objc func onNotificationCounterChanged(notification: Notification) {
        guard let counters = notification.userInfo?["counters"] as? [Int] else { return }
    }
}
extension FriendsViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return searchedFriendViewModel.cell.count
        }
        return section == 0 ? (importantFriendViewModel.cell.count < 5 ? importantFriendViewModel.cell.count : 5) : friendViewModel.cell.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsTableViewCell", for: indexPath) as! FriendsTableViewCell
        cell.selectionStyle = .none
        if isFiltering {
            cell.setup(by: searchedFriendViewModel.cell[indexPath.row])
            return cell
        }
        cell.setup(by: indexPath.section == 0 ? importantFriendViewModel.cell[indexPath.row] : friendViewModel.cell[indexPath.row])
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let presenter = presenter, let userId = indexPath.section == 0 ? importantFriendViewModel.cell[indexPath.row].id : friendViewModel.cell[indexPath.row].id else { return }
        presenter.onTapFriend(from: userId)
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return isFiltering ? 1 : 2
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard friendViewModel.cell.count > 0 && !isFiltering else { return nil }
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        returnedView.backgroundColor = .getThemeableColor(fromNormalColor: .white)
        let label = UILabel()
        returnedView.addSubview(label)
        label.autoPinEdge(.top, to: .top, of: returnedView, withOffset: 12)
        label.autoPinEdge(.leading, to: .leading, of: returnedView, withOffset: 16)
        label.autoPinEdge(.trailing, to: .trailing, of: returnedView, withOffset: -16)
        label.autoPinEdge(.bottom, to: .bottom, of: returnedView, withOffset: -8)
        label.autoSetDimension(.height, toSize: 22)
        switch section {
        case 0:
            let attributedText = NSAttributedString(string: "Важные", attributes: [.font: GoogleSansFont.bold(with: 18), .foregroundColor: UIColor.adaptableBlack])
            label.attributedText = attributedText
            
        case 1:
            let attributedText = NSAttributedString(string: "Все друзья  ", attributes: [.font: GoogleSansFont.bold(with: 18), .foregroundColor: UIColor.adaptableBlack]) + NSAttributedString(string: " \(friendViewModel.cell.count)", attributes: [.font: GoogleSansFont.medium(with: 13), .foregroundColor: UIColor.adaptableDarkGrayVK])
            label.attributedText = attributedText
            
        default: label.text = ""
        }
        return returnedView
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard friendViewModel.cell.count > 0, !isFiltering else { return 0 }
        return 44
    }
}
extension FriendsViewController: UISearchResultsUpdating, UISearchBarDelegate, UITextFieldDelegate {
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }
    
    public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
    }
    
    public func updateSearchResults(for searchController: UISearchController) {
        guard let pattern = searchController.searchBar.text?.trimmed, 0 < pattern.utf16.count else {
            footerView.footerTitle = friendViewModel.cell.count > 0 ? "\(friendViewModel.cell.count) \(getStringByDeclension(number: friendViewModel.cell.count, arrayWords: Localization.friendsCount))" : "Нет друзей"
            mainTable.reloadData()
            return
        }

        searchedFriendViewModel.cell = friendViewModel.cell.filter { cellModel in
            return cellModel.firstName!.contains(pattern) || cellModel.lastName!.contains(pattern) || "\(cellModel.firstName!) \(cellModel.lastName!)".contains(pattern)
        }
        footerView.footerTitle = searchedFriendViewModel.cell.count > 0 ? "\(searchedFriendViewModel.cell.count) \(getStringByDeclension(number: searchedFriendViewModel.cell.count, arrayWords: Localization.searchedCount))" : "По запросу \"\(pattern)\" никого не найдено"
        mainTable.reloadData { [weak self] in
            guard let self = self else { return }
            self.mainTable.layoutIfNeeded()
        }
    }
}
extension FriendsViewController {
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
