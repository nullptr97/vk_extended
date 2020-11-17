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

open class FriendsViewController: BaseViewController, FriendsViewProtocol {
    var presenter: FriendsPresenterProtocol?
    private let mainTable = UITableView(frame: .zero, style: .grouped)
    private var friendViewModel = FriendViewModel.init(cell: [], footerTitle: nil)
    private var importantFriendViewModel = FriendViewModel.init(cell: [], footerTitle: nil)
    private var searchedFriendViewModel = FriendViewModel.init(cell: [], footerTitle: nil)
    private lazy var footerView = FooterView(frame: CGRect(origin: .zero, size: .custom(screenWidth, 44)))
    private lazy var refreshControl = DRPRefreshControl()
    private lazy var searchController = SearchBarController()
    private var isSearched: Bool = false

    open override func viewDidLoad() {
        super.viewDidLoad()
                
        FriendsRouter.initModule(self)
        presenter?.start(request: .getFriend(userId: Constants.currentUserId))
        
        title = "Друзья"
        setupButtons()
        
        prepareTable()
        setupTable()
    }
    
    // Подготовка таблицы
    func prepareTable() {
        view.addSubview(mainTable)
        mainTable.autoPinEdge(toSuperviewSafeArea: .top, withInset: 56)
        mainTable.autoPinEdge(toSuperviewSafeArea: .bottom, withInset: 52)
        mainTable.autoPinEdge(.trailing, to: .trailing, of: view)
        mainTable.autoPinEdge(.leading, to: .leading, of: view)
    }
    
    // Настройка таблицы
    func setupTable() {
        mainTable.backgroundColor = .adaptableWhite
        mainTable.keyboardDismissMode = .onDrag
        mainTable.allowsMultipleSelection = false
        mainTable.allowsMultipleSelectionDuringEditing = true
        mainTable.separatorStyle = .none
        mainTable.delegate = self
        mainTable.dataSource = self
        mainTable.register(UINib(nibName: "FriendsTableViewCell", bundle: nil), forCellReuseIdentifier: "FriendsTableViewCell")
        refreshControl.add(to: mainTable, target: self, selector: #selector(reloadFriends))
        refreshControl.loadingSpinner.colorSequence = [.adaptableDarkGrayVK]
        refreshControl.loadingSpinner.lineWidth = 2.5
        refreshControl.loadingSpinner.rotationCycleDuration = 1
        mainTable.tableFooterView = footerView
        mainTable.tableHeaderView = searchController.searchBar
        setupSearchBar()
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
        searchController.searchBar.delegate = self
    }
    
    // Настройка кнопок
    func setupButtons() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.appBarViewController.navigationBar.trailingBarButtonItems = [UIBarButtonItem(image: UIImage(named: "list_outline_28")?.withRenderingMode(.alwaysTemplate).tint(with: .systemBlue), style: .plain, target: self, action: nil), UIBarButtonItem(image: UIImage(named: "user_add_outline_28")?.withRenderingMode(.alwaysTemplate).tint(with: .systemBlue), style: .plain, target: self, action: nil)]
        }
    }
    
    // Отобразить данные
    func displayData(viewModel: FriendModel.ViewModel.ViewModelData) {
        switch viewModel {
        case .displayFriend(friendViewModel: let friendsViewModel):
            self.friendViewModel = sortedFriends(friendsViewModel: friendsViewModel)
            self.importantFriendViewModel = friendsViewModel
            footerView.footerTitle = friendsViewModel.cell.count > 0 ? "\(friendsViewModel.cell.count) \(getStringByDeclension(number: friendsViewModel.cell.count, arrayWords: Localization.instance.friendsCount))" : "Нет друзей"
            mainTable.reloadData() 
            refreshControl.endRefreshing()
        case .displayFooterLoader:
            footerView.footerTitle = nil
        case .displayFooterError(message: let message):
            footerView.footerTitle = message
            mainTable.reloadData()
            refreshControl.endRefreshing()
        default:
            break
        }
    }
    
    // Сортировка друзей аля "оригинальный вк"
    func sortedFriends(friendsViewModel: FriendViewModel) -> FriendViewModel {
        var sortedFriendsViewModel = friendsViewModel
        var sortedIndex = 0
        while sortedIndex < 5 {
            sortedFriendsViewModel.cell.remove(at: 0)
            sortedFriendsViewModel.cell.insert(friendsViewModel.cell[sortedIndex], at: friendsViewModel.cell.count - 1)
            sortedIndex += 1
        }
        return sortedFriendsViewModel
    }

    // При обновлении страницы
    @objc func reloadFriends() {
        presenter?.start(request: .getFriend(userId: Constants.currentUserId))
    }
}
extension FriendsViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearched {
            return searchedFriendViewModel.cell.count
        }
        return section == 0 ? (importantFriendViewModel.cell.count < 5 ? importantFriendViewModel.cell.count : 5) : friendViewModel.cell.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsTableViewCell", for: indexPath) as! FriendsTableViewCell
        cell.selectionStyle = .none
        if isSearched {
            cell.setup(by: searchedFriendViewModel.cell[indexPath.row])
            return cell
        }
        cell.setup(by: indexPath.section == 1 ? friendViewModel.cell[indexPath.row] : importantFriendViewModel.cell[indexPath.row])
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
        return isSearched ? 1 : 2
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard friendViewModel.cell.count > 0 && !isSearched else { return nil }
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        returnedView.backgroundColor = .adaptableWhite
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
            let attributedText = NSAttributedString(string: "Все друзья  ", attributes: [.font: GoogleSansFont.bold(with: 18), .foregroundColor: UIColor.adaptableBlack]) + NSAttributedString(string: " \(importantFriendViewModel.cell.count)", attributes: [.font: GoogleSansFont.medium(with: 13), .foregroundColor: UIColor.adaptableDarkGrayVK])
            label.attributedText = attributedText
            
        default: label.text = ""
        }
        return returnedView
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard friendViewModel.cell.count > 0, !isSearched else { return 0 }
        return 44
    }
}
extension FriendsViewController: SearchBarDelegate {
    public func searchBar(searchBar: SearchBar, didChange textField: UITextField, with text: String?) {
        guard let pattern = text?.trimmed, 0 < pattern.utf16.count else {
            isSearched = false
            footerView.footerTitle = friendViewModel.cell.count > 0 ? "\(friendViewModel.cell.count) \(getStringByDeclension(number: friendViewModel.cell.count, arrayWords: Localization.instance.friendsCount))" : "Нет друзей"
            mainTable.reloadData()
            return
        }
        isSearched = true

        searchedFriendViewModel.cell = friendViewModel.cell.filter { cellModel in
            return cellModel.firstName!.contains(pattern) || cellModel.lastName!.contains(pattern) || "\(cellModel.firstName!) \(cellModel.lastName!)".contains(pattern)
        }
        footerView.footerTitle = searchedFriendViewModel.cell.count > 0 ? "\(searchedFriendViewModel.cell.count) \(getStringByDeclension(number: searchedFriendViewModel.cell.count, arrayWords: Localization.instance.searchedCount))" : "По запросу \"\(pattern)\" никого не найдено"
        mainTable.reloadData()
    }
    
    public func searchBar(searchBar: SearchBar, willClear textField: UITextField, with text: String?) {
        isSearched = false
        footerView.footerTitle = friendViewModel.cell.count > 0 ? "\(friendViewModel.cell.count) \(getStringByDeclension(number: friendViewModel.cell.count, arrayWords: Localization.instance.friendsCount))" : "Нет друзей"
        mainTable.reloadData()
    }
}
