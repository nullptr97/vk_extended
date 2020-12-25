//
//  SettingsViewController.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 26.11.2020.
//

import UIKit
import MaterialComponents
import Material

class UISettingsViewController: BaseViewController {

    private let mainTable = UITableView(frame: .zero, style: .grouped)
    private let titles: [String] = ["Иконка"]
    private let types: [[UISetType]] = {
        if #available(iOS 13.0, *) {
            return [[.icon, .amoledTheme]]
        } else {
            return  [[.icon]]
        }
    }()
    private let imagesString: [[String]] = [["user_circle_outline_28", "moon_outline_28"]]
    private let states: [[Bool]] = [[UserDefaults.standard.bool(forKey: "alternateIcon"), UserDefaults.standard.bool(forKey: "isAmoledTheme")]]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationTitle = "Настройки"
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
        mainTable.register(UINib(nibName: "UISettingsTableViewCell", bundle: nil), forCellReuseIdentifier: "UISettingsTableViewCell")
    }
}
extension UISettingsViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return types[section].count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UISettingsTableViewCell", for: indexPath) as! UISettingsTableViewCell
        cell.selectionStyle = .none
        cell.cellType = types[indexPath.section][indexPath.row]
        cell.settingsLabel.text = types[indexPath.section][indexPath.row].rawValue
        cell.settingsImageView.image = UIImage(named: imagesString[indexPath.section][indexPath.row])?.withRenderingMode(.alwaysTemplate).tint(with: .getAccentColor(fromType: .common))
        cell.setState(states[indexPath.section][indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = TableHeader(frame: CGRect(origin: .zero, size: .custom(tableView.bounds.width, 36)))
        header.headerTitle = titles[section].uppercased()
        header.dividerVisibility = section == 0 ? .invisible : .visible
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
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
extension UISettingsViewController: MenuCellDelegate {
    func onOpenMenuItem(for cell: MenuTableViewCell) {
        return
    }

    func onChangeSwitchState(for cell: UISettingsTableViewCell, state: Bool) {
        switch cell.cellType {
        case .icon:
            UserDefaults.standard.set(state, forKey: "alternateIcon")
            guard UIApplication.shared.supportsAlternateIcons else { return }
            UIApplication.shared.setAlternateIconName(!state ? "extended1" : "extended2", completionHandler: { (error) in
                if let error = error {
                    print("App icon failed to change due to \(error.localizedDescription)")
                } else {
                    print("App icon changed successfully")
                }
            })
        case .amoledTheme:
            if #available(iOS 13.0, *) {
                if traitCollection.userInterfaceStyle == .dark {
                    showAlert(title: "Смена темы", message: "Приложение будет закрыто", buttonTitles: ["OK"], highlightedButtonIndex: 0, completion: { (index) in
                        if index == 0 {
                            UserDefaults.standard.set(state, forKey: "isAmoledTheme")
                            exit(0)
                        }
                    })
                } else {
                    UserDefaults.standard.set(state, forKey: "isAmoledTheme")
                }
            }
        }
    }
}
