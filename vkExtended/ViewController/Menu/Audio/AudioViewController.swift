//
//  AudioViewController.swift
//  vkExtended
//
//  Created Ярослав Стрельников on 15.11.2020.
//  Copyright © 2020 ExtendedTeam. All rights reserved.
//
import UIKit
import Material
import MBProgressHUD
import MaterialComponents
import Material
import DRPLoadingSpinner
import SwiftMessages

class AudioViewController: BaseViewController, AudioViewProtocol {

	var presenter: AudioPresenterProtocol?
    let mainTable = TableView(frame: .zero, style: .plain)
    private lazy var searchController = SearchBarController()

    private var audioViewModel = [AudioViewModel]()
    
    private var audioService: AudioService?
    
    private let playButton = IconButton(image: UIImage(named: "play_48")?.crop(toWidth: 24, toHeight: 24)?.withRenderingMode(.alwaysTemplate).tint(with: .getAccentColor(fromType: .common)), tintColor: .getAccentColor(fromType: .common))
    private let shuffleButton = IconButton(image: UIImage(named: "shuffle_24")?.crop(toWidth: 24, toHeight: 24)?.withRenderingMode(.alwaysTemplate).tint(with: .getAccentColor(fromType: .common)), tintColor: .getAccentColor(fromType: .common))

    deinit {
        removeNotificationsObserver()
    }
    
	override func viewDidLoad() {
        super.viewDidLoad()
        
        AudioRouter.initModule(self)
        presenter?.onStart()

        navigationTitle = "Музыка"
        prepareTable()
        setupTable()
        
        setNavigationItems(rightNavigationItems: [playButton, shuffleButton])
        setupStatusView()
        addNotificationObserver(name: .onPlayerStateChanged, selector: #selector(reloaData))
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        mainTable.reloadData()
        
        setNavigationItems(rightNavigationItems: [playButton, shuffleButton])
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
        mainTable.contentInsetAdjustmentBehavior = .never
        
    }
    
    // Настройка таблицы
    func setupTable() {
        mainTable.keyboardDismissMode = .onDrag
        mainTable.allowsMultipleSelection = false
        mainTable.allowsMultipleSelectionDuringEditing = true
        mainTable.separatorStyle = .none
        mainTable.delegate = self
        mainTable.dataSource = self
        mainTable.register(UINib(nibName: "AudioTableViewCell", bundle: nil), forCellReuseIdentifier: "AudioTableViewCell")
        
        mainTable.addRefreshHeader { [weak self] (footer) in
            guard let self = self else { return }
            self.reloadAudio()
        }
        
        mainTable.addRefreshFooter { [weak self] (footer) in
            guard let self = self else { return }
        }

        nativeSearchController.setupSearchBar()
        mainTable.tableHeaderView = nativeSearchController.searchBar
    }
    
    // Показать загрузку
    func presentLoader(with error: String = "") {
        if error.isEmpty {
            mainTable.refreshHeader?.success(withDelay: 1)
            mainTable.refreshFooter?.success(withDelay: 1)
        } else {
            mainTable.refreshFooter?.error(error)
            mainTable.refreshHeader?.error(error)
        }
        mainTable.reloadData()
    }
    
    // Показать музыку
    func presentAudio(audioViewModels: [AudioViewModel]) {
        audioViewModel = audioViewModels
        mainTable.reloadData()
        refreshControl.endRefreshing()

        mainTable.refreshHeader?.success(withDelay: 1)
        mainTable.refreshFooter?.success(withDelay: 1)
        AudioService.instance.items = audioViewModels.compactMap { AudioItem(highQualitySoundURL: URL(string: $0.url), itemId: $0.id, model: $0) }
    }
    
    // При обновлении таблицы
    @objc func reloaData() {
        mainTable.reloadData()
    }
    
    // При обновлении страницы
    @objc func reloadAudio() {
        presenter?.onStart()
    }
}
extension AudioViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioViewModel.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AudioTableViewCell", for: indexPath) as! AudioTableViewCell
        cell.selectionStyle = .none
        cell.setupCell(audioViewModel: audioViewModel[indexPath.row], state: getCellState(at: indexPath))
        return cell
    }
    
    func getCellState(at indexPath: IndexPath) -> AudioCellState {
        if AudioService.instance.player.currentItem?.itemId == audioViewModel[indexPath.row].id {
            switch AudioService.instance.player.state {
            case .buffering:
                return .playing
            case .playing:
                return .playing
            case .paused:
                return .paused
            case .stopped:
                return .notPlaying
            case .waitingForConnection:
                return .notPlaying
            case .failed(_):
                return .notPlaying
            }
        } else {
            return .notPlaying
        }
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let header = TableHeader(frame: CGRect(origin: .zero, size: .custom(tableView.bounds.width, section == titles.count - 1 ? 1 : 36)))
//        header.headerTitle = titles[section].uppercased()
//        header.dividerVisibility = section == 0 ? .invisible : .visible
//        return header
//    }
//
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if AudioService.instance.player.state == .playing && AudioService.instance.player.currentItem?.itemId == audioViewModel[indexPath.row].id {
            tabBarController?.openPopup(animated: true, completion: nil)
        } else if AudioService.instance.player.state == .paused && AudioService.instance.player.currentItem?.itemId == audioViewModel[indexPath.row].id {
            AudioService.instance.action(.resume)
        } else {
            AudioService.instance.action(.play, index: indexPath.row)
        }
        tableView.reloadRows(at: tableView.indexPathsForVisibleRows ?? [], with: .none)
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
