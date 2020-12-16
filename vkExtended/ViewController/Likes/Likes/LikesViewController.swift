//
//  LikesViewController.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 03.12.2020.
//

import UIKit
import Material

class LikesViewController: UIViewController {
    var likesTabsController: LikesTabsViewController? {
        return tabsController as? LikesTabsViewController
    }
    
    private let mainTable = TableView(frame: .zero, style: .plain)
    private var profilesViewModel = FriendViewModel.init(cell: [], footerTitle: nil, count: 0)

    let postId: Int
    let sourceId: Int
    let type: String

    init(postId: Int, sourceId: Int, type: String) {
        self.postId = postId
        self.sourceId = sourceId
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()

        prepareTabItem()
        prepareTable()
        setupTable()
        
        likesTabsController?.presenter?.start(request: .getLikes(postId: postId, sourceId: sourceId, type: type))
    }
    
    // Подготовка таблицы
    func prepareTable() {
        view.addSubview(mainTable)
        mainTable.separatorStyle = .none
        mainTable.autoPinEdge(.top, to: .top, of: view, withOffset: UIDevice.type.rawValue < 15 ? (2 * toolbarHeight) - 24 : 2 * toolbarHeight)
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
        mainTable.register(UINib(nibName: "FriendsTableViewCell", bundle: nil), forCellReuseIdentifier: "FriendsTableViewCell")
        
        mainTable.addRefreshHeader { [weak self] (header) in
            guard let self = self else { return }
            self.likesTabsController?.makeRequest()
        }
        
        mainTable.refreshHeader?.start()
    }
    
    // Подготовка элемента таббара
    fileprivate func prepareTabItem() {
        tabItem.title = "oценили"
        tabItem.setTabItemColor(.adaptableBlack, for: .selected)
        tabItem.setTabItemColor(.adaptableDarkGrayVK, for: .normal)
        tabItem.titleLabel?.font = GoogleSansFont.bold(with: 17)
        tabItem.titleLabel?.adjustsFontSizeToFitWidth = true
        tabItem.titleLabel?.allowsDefaultTighteningForTruncation = true
    }
    
    // Отобразить данные
    func displayData(viewModel: FriendViewModel) {
        self.profilesViewModel = viewModel

        tabItem.title = "\(viewModel.cell.count) оценили"

        mainTable.reloadData()
        mainTable.refreshHeader?.success(withDelay: 1)
        mainTable.refreshFooter?.success(withDelay: 1)
    }
}
extension LikesViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profilesViewModel.cell.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsTableViewCell", for: indexPath) as! FriendsTableViewCell
        cell.selectionStyle = .none
        cell.setup(by: profilesViewModel.cell[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
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
