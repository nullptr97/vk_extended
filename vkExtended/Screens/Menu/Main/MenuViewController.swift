//
//  MenuViewController.swift
//  vkExtended
//
//  Created Ярослав Стрельников on 15.11.2020.
//  Copyright © 2020 ExtendedTeam. All rights reserved.
//
import UIKit
import Material

class MenuViewController: BaseViewController, MenuViewProtocol {

	var presenter: MenuPresenterProtocol?
    private let mainTable = TableView(frame: .zero, style: .grouped)
    private let titles: [String] = ["Контент", "Личное", "Настройки", ""]
    private let types: [[CellType]] = [[.audio, .groups, .videos], [.files, .bookmarks, .liked], [.ui, .messages, .newsfeed], [.dev, .logout]]
    private let imagesString: [[String]] = [["music_outline_28", "users_3_outline_28", "video_outline_28"], ["document_outline_28", "favorite_outline_28", "like_outline_28"], ["palette_outline_28", "messages_outline_28 @ chats", "news"], ["bug_outline_28", "cancel_outline_28"]]

	override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationTitle = "Меню"
        prepareTable()
        setupTable()
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        mainTable.reloadData()
    }

    // Подготовка таблицы
    func prepareTable() {
        view.addSubview(mainTable)
        mainTable.separatorStyle = .none
        mainTable.autoPinEdge(toSuperviewSafeArea: .top, withInset: 12)
        mainTable.autoPinEdge(.bottom, to: .bottom, of: view)
        mainTable.autoPinEdge(.trailing, to: .trailing, of: view)
        mainTable.autoPinEdge(.leading, to: .leading, of: view)
        mainTable.backgroundColor = .getThemeableColor(fromNormalColor: .white)
        
    }
    
    // Настройка таблицы
    func setupTable() {
        mainTable.keyboardDismissMode = .onDrag
        mainTable.allowsMultipleSelection = false
        mainTable.allowsMultipleSelectionDuringEditing = true
        mainTable.separatorStyle = .none
        mainTable.delegate = self
        mainTable.dataSource = self
        mainTable.register(UINib(nibName: "MenuTableViewCell", bundle: nil), forCellReuseIdentifier: "MenuTableViewCell")
    }
}
extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return types[section].count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableViewCell", for: indexPath) as! MenuTableViewCell
        cell.selectionStyle = .none
        cell.itemTitle = types[indexPath.section][indexPath.row].rawValue
        cell.cellType = types[indexPath.section][indexPath.row]
        cell.itemImage = UIImage(named: imagesString[indexPath.section][indexPath.row])
        cell.itemImageTint = (indexPath.section == titles.count - 1 && indexPath.row == types[titles.count - 1].count - 1) ? .extendedBackgroundRed : .getAccentColor(fromType: .common)
        cell.itemTitleTint = (indexPath.section == titles.count - 1 && indexPath.row == types[titles.count - 1].count - 1) ? .extendedBackgroundRed : .getThemeableColor(fromNormalColor: .black)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = TableHeader(frame: CGRect(origin: .zero, size: .custom(tableView.bounds.width, section == titles.count - 1 ? 18 : 36)))
        header.headerTitle = titles[section].uppercased()
        header.dividerVisibility = section == 0 ? .invisible : .visible
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == titles.count - 1 ? 1 : 36
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return titles.count
    }
}
extension MenuViewController: MenuCellDelegate {
    func onOpenMenuItem(for cell: MenuTableViewCell) {
        switch cell.cellType {
        case .audio:
            let audioViewController = AudioViewController()
            navigationController?.pushViewController(audioViewController)
        case .groups:
            break
        case .videos:
            break
        case .files:
            break
        case .bookmarks:
            break
        case .liked:
            break
        case .ui:
            let uiSettingsViewController = UISettingsViewController()
            navigationController?.pushViewController(uiSettingsViewController)
        case .messages:
            break
        case .newsfeed:
            break
        case .dev:
            let testingViewController = TestingViewController()
            navigationController?.pushViewController(testingViewController)
        case .logout:
            showAlert(title: "Подтверждение", message: "Вы действительно хотите выйти из аккаута?", buttonTitles: ["Да", "Отмена"], highlightedButtonIndex: 1) { (index) in
                if index == 0 {
                    DispatchQueue.global(qos: .background).async {
                        VK.sessions.default.logOut()
                        DispatchQueue.main.async {
                            let rootViewController = UIApplication.shared.windows.first!.rootViewController as! FullScreenNavigationController
                            rootViewController.popToRootViewController(animated: false)
                            rootViewController.pushViewController(LoginViewController(), animated: true)
                        }
                    }
                }
            }
        }
    }
    
    func onChangeSwitchState(for cell: UISettingsTableViewCell, state: Bool) {
    }
}
