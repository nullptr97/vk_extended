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
        presenter?.onStart(ownerId: currentUserId)

//        navigationTitle = "Музыка"
        prepareTable()
        setupTable()
        
        // setNavigationItems(rightNavigationItems: [playButton, shuffleButton])
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
        mainTable.register(UINib(nibName: "AudioTableViewCell", bundle: nil), forCellReuseIdentifier: "AudioTableViewCell")
        refreshControl.add(to: mainTable) { [weak self] in
            guard let self = self else { return }
            self.reloadAudio()
        }

        nativeSearchController.setupSearchBar()
        navigationItem.centerViews = [nativeSearchController.searchBar]
    }
    
    // Показать загрузку
    func presentLoader(with error: String = "") {
        mainTable.reloadData()
    }
    
    // Показать музыку
    func presentAudio(audioViewModels: [AudioViewModel]) {
        audioViewModel = audioViewModels
        mainTable.reloadData()
        refreshControl.endRefreshing()
        AudioService.instance.items = audioViewModels.compactMap { AudioItem(highQualitySoundURL: URL(string: $0.url), itemId: $0.id, model: $0) }
    }
    
    // Обработка долгого нажатия на диалог
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer?) {
        guard let point = gestureRecognizer?.location(in: mainTable), !mainTable.isEditing else { return }
        guard let indexPath = mainTable.indexPathForRow(at: point) else { return }
        if gestureRecognizer?.state == .began {
            let audio = audioViewModel[indexPath.row]
            initialActionSheet(title: audio.title, message: audio.artist, actions: getActions(at: indexPath))
        }
    }
    
    // При обновлении таблицы
    @objc func reloaData() {
        mainTable.reloadData()
    }
    
    // При обновлении страницы
    @objc func reloadAudio() {
        presenter?.onStart(ownerId: currentUserId)
    }
}
extension AudioViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioViewModel.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AudioTableViewCell", for: indexPath) as! AudioTableViewCell
        AudioService.instance.items[indexPath.row].delegate = self
        cell.selectionStyle = .none
        cell.setupCell(audioViewModel: audioViewModel[indexPath.row], state: getCellState(at: indexPath))
        cell.audioTitleLabel.attributedText = AudioService.instance.items[indexPath.row].isLoaded ? cell.audioTitleLabel.attributedText! + setLabelImage(image: "download_outline_16")! : cell.audioTitleLabel.attributedText!
        if !(Reachability()?.isReachable ?? true) {
            cell.contentView.alpha = !AudioService.instance.items[indexPath.row].isLoaded ? 0.5 : 1
            cell.isUserInteractionEnabled = !AudioService.instance.items[indexPath.row].isLoaded ? false : true
        } else {
            cell.contentView.alpha = 1
            cell.isUserInteractionEnabled = true
        }
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
        return 60
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
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
extension AudioViewController {
    // Получение доступных с другом действий
    func getActions(at indexPath: IndexPath) -> [MDCActionSheetAction] {
        let deleteAudio = MDCActionSheetAction(title: "Удалить аудиозапись", image: UIImage(named: "delete_outline_28"), handler: { [weak self] action in
            guard let self = self else { return }
            self.dialog(title: "Удалить \"\(self.audioViewModel[indexPath.row].title)\"?", icon: "music_outline_56", buttonTitle: "Удалить", secondButtonTitle: "Отмена") { (_) in
                SwiftMessages.hide()
            } _: { (_) in
                SwiftMessages.hide()
            }
        })
        let saveAudio = MDCActionSheetAction(title: "Сохранить в кэш", image: UIImage(named: "download_cloud_outline_28"), handler: { [weak self] action in
            guard let self = self else { return }
            AudioService.instance.items[indexPath.row].download()
        })
        deleteAudio.titleColor = .extendedBackgroundRed
        deleteAudio.tintColor = .extendedBackgroundRed
        
        return [saveAudio, deleteAudio]
    }
}
extension AudioViewController: CachingPlayerItemDelegate {
    func playerItem(_ playerItem: AudioItem, didDownloadBytesSoFar bytesDownloaded: Int, outOf bytesExpected: Int) {
        print("\(bytesDownloaded) / \(bytesExpected)")
    }
    
    func playerItem(_ playerItem: AudioItem, didFinishDownloadingData data: Data) {
        self.event(message: "Аудиозапись загружена", isError: false)
    }
    
    func playerItem(_ playerItem: AudioItem, downloadingFailedWith error: Error) {
        self.event(message: error.localizedDescription, isError: true)
    }
}
