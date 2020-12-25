//
//  ProfileViewController.swift
//  vkExtended
//
//  Created Ярослав Стрельников on 26.10.2020.
//  Copyright © 2020 ExtendedTeam. All rights reserved.
//
import UIKit
import MaterialComponents
import Material
import DRPLoadingSpinner
import IGListKit
import SwiftMessages
import Kingfisher

class ProfileViewController: BaseViewController, ProfileViewProtocol {
    let mainCollection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private var profileViewModel: ProfileViewModel = ProfileViewModel.init(cell: nil, footerTitle: nil)
    private var photosViewModel = PhotoViewModel.init(cell: [], footerTitle: nil, count: 0)
    private var friendsViewModel = FriendViewModel.init(cell: [], footerTitle: nil, count: 0)
    private var wallViewModel = FeedViewModel.init(cells: [], footerTitle: nil)
    private lazy var footerView = FooterView(frame: CGRect(origin: .zero, size: .custom(screenWidth, 44)))
    private lazy var adapter: ListAdapter = {
        let listAdapter = ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 1)
        listAdapter.collectionView = mainCollection
        listAdapter.dataSource = self
        return listAdapter
    }()

    internal var presenter: ProfilePresenterProtocol?
    var userId: Int
    
    private let fullInfoButton = IconButton(image: UIImage(named: "info_circle_outline_28")?.withRenderingMode(.alwaysTemplate).tint(with: .getAccentColor(fromType: .common)), tintColor: .getAccentColor(fromType: .common))
    private let moreButton = IconButton(image: UIImage(named: "more_horizontal_28")?.withRenderingMode(.alwaysTemplate).tint(with: .getAccentColor(fromType: .common)), tintColor: .getAccentColor(fromType: .common))
    
    private var isCurrentProfile: Bool {
        return currentUserId == userId
    }
    
    init(userId: Int) {
        self.userId = userId
        super.init(nibName: nil, bundle: nil)
        
        ProfileRouter.initModule(self)
    }
    
    init(profileViewModel: ProfileViewModel) {
        self.userId = profileViewModel.cell?.id ?? currentUserId
        super.init(nibName: nil, bundle: nil)
        self.profileViewModel = profileViewModel
        
        ProfileRouter.initModule(self)

        _ = adapter
    }
    
    required init?(coder: NSCoder) {
        self.userId = currentUserId
        super.init(nibName: nil, bundle: nil)
        
        ProfileRouter.initModule(self)
    }
    
	override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.start(request: .getProfile(userId: userId))
        
        setupBackground()
        
        prepareCollection()
        setupCollection()
        
        navigationTitle = "Профиль"
        navigationSubtitle = " "
        
        fullInfoButton.addTarget(self, action: #selector(onFullInfoOpen), for: .touchUpInside)
        moreButton.addTarget(self, action: #selector(moreMenu), for: .touchUpInside)
        
        setNavigationItems(rightNavigationItems: isCurrentProfile ? [] : [moreButton])
        setupStatusView()
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setNavigationItems(rightNavigationItems: isCurrentProfile ? [] : [moreButton])
    }
    
    // Подготовка коллекции
    func prepareCollection() {
        view.addSubview(mainCollection)
        mainCollection.autoPinEdge(toSuperviewSafeArea: .top, withInset: 12)
        mainCollection.autoPinEdge(.bottom, to: .bottom, of: view)
        mainCollection.autoPinEdge(.trailing, to: .trailing, of: view)
        mainCollection.autoPinEdge(.leading, to: .leading, of: view)
        mainCollection.backgroundColor = .getThemeableColor(fromNormalColor: .white)
        adapter.collectionViewDelegate = self
    }
    
    // Настройка коллекции
    func setupCollection() {
        mainCollection.keyboardDismissMode = .onDrag
        mainCollection.allowsMultipleSelection = true
        refreshControl.add(to: mainCollection) { [weak self] in
            guard let self = self else { return }
            self.presenter?.start(request: .getProfile(userId: self.userId))
        }
    }

    // Отобразить данные
    func displayData(viewModel: ProfileModel.ViewModel.ViewModelData) {
        switch viewModel {
        case .displayProfile(profileViewModel: let profileViewModel, photosViewModel: let photosViewModel, friendsViewModel: let friendsViewModel):
            navigationItem.titleLabel.fadeTransition(0.3)
            navigationItem.detailLabel.fadeTransition(0.3)

            navigationTitle = profileViewModel.cell?.screenName
            navigationSubtitle = profileViewModel.cell?.getOnline()
            
            self.profileViewModel = profileViewModel
            self.photosViewModel = photosViewModel
            self.friendsViewModel = friendsViewModel
            
            if !(profileViewModel.cell?.canAccessClosed ?? true) {
                refreshControl.endRefreshing()
            }

            adapter.reloadData { [weak self] (updated) in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.mainCollection.reloadData()
                }
            }
        case .displayProfileFriends(friendsViewModel: let friendsViewModel):
            self.friendsViewModel = friendsViewModel
            
            adapter.reloadData { [weak self] (updated) in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.mainCollection.reloadData()
                    self.refreshControl.endRefreshing()
                }
            }
        case .displayProfileWall(wallViewModel: let wallViewModel):
            self.wallViewModel = wallViewModel
            
            adapter.reloadData { [weak self] (updated) in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.mainCollection.reloadData()
                    self.refreshControl.endRefreshing()
                }
            }
        case .displayFooterLoader:
            break
        case .displayFooterError(message: let messageError):
            footerView.footerTitle = messageError
            mainCollection.reloadData()
        }
    }
    
    // При обновлении страницы
    @objc func reloadProfile() {
        presenter?.start(request: .getProfile(userId: userId))
    }
    
    // При подгрузке дополнительных новостей
    @objc func getNext() {
        presenter?.start(request: .getNextBatch(userId: userId))
    }
    
    // Подробная инфа
    @objc func onFullInfoOpen() {
        
    }
    
    @objc func moreMenu() {
        initialActionSheet(title: nil, message: nil, actions: moreActions)
    }
}
extension ProfileViewController: UICollectionViewDelegate { }
extension ProfileViewController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        guard let profileData = profileViewModel.cell else { return [] }
        var data: [ListDiffable] = [profileData]
        if profileData.canAccessClosed {
            if !friendsViewModel.cell.isEmpty {
                data.append(friendsViewModel)
            }
            if !photosViewModel.cell.isEmpty {
                data.append(photosViewModel)
            }
            if !wallViewModel.cells.isEmpty {
                data.append(contentsOf: wallViewModel.cells)
            }
        }
        return data
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        switch object {
        case is ProfileViewModel.Cell:
            return ProfileSectionController()
        case is PhotoViewModel:
            return PhotosSectionController()
        case is FriendViewModel:
            return FriendsSectionController()
        case is FeedViewModel.Cell:
            return NewsSectionController()
        default:
            return ListSectionController()
        }
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return mainCollection.backgroundView
    }
}
extension ProfileViewController {
    // Получение доступных с профилем действий
    var moreActions: [MDCActionSheetAction] {
        let addToChat = MDCActionSheetAction(title: "Добавить в беседу", image: UIImage(named: "message_add_badge_outline_28"), handler: { action in
        })
        let saveFavorite = MDCActionSheetAction(title: "Сохранить в заклыдки", image: UIImage(named: "favorite_outline_28"), handler: { action in
        })
        let shareUrl = MDCActionSheetAction(title: "Поделиться ссылкой", image: UIImage(named: "share_outline_28"), handler: { action in
        })
        let copyUrl = MDCActionSheetAction(title: "Скопировать ссылку", image: UIImage(named: "copy_outline_28"), handler: { action in
        })
        let report = MDCActionSheetAction(title: "Пожаловаться", image: UIImage(named: "report_outline_28"), handler: { action in
        })
        let banFriend = MDCActionSheetAction(title: "Отправить в черный список", image: UIImage(named: "block_outline_28"), handler: { action in
        })
        banFriend.titleColor = .extendedBackgroundRed
        banFriend.tintColor = .extendedBackgroundRed
        
        return [addToChat, saveFavorite, shareUrl, copyUrl, report, banFriend]
    }
    
    // Получение доступных с другом действий
    func getFriendActions(with friendAction: FriendAction) -> [MDCActionSheetAction] {
        var actions = [MDCActionSheetAction]()
        
        switch friendAction {
        case .requestSend:
            actions.append(MDCActionSheetAction(title: "Отписаться", image: UIImage(named: friendAction.setImage(from: friendAction)), handler: { action in
                
            }))
        case .incomingRequest:
            actions.append(MDCActionSheetAction(title: "Добавить в друзья", image: UIImage(named: friendAction.setImage(from: friendAction)), handler: { action in
                
            }))
        case .isFriend:
            actions.append(MDCActionSheetAction(title: "Удалить из друзей", image: UIImage(named: friendAction.setImage(from: friendAction)), handler: { action in
                
            }))
        default: break
        }
        
        return actions
    }
}
extension ProfileViewController {
    func presentationOptionsForUISelections() -> SheetPresentationOptions {
        return SheetPresentationOptions(
            cornerOptions: .roundAllCorners(radius: 12),
            dimmingViewAlpha: 0.7,
            edgeInsets: NSDirectionalEdgeInsets(top: CGFloat(12), leading: CGFloat(12), bottom: CGFloat(12), trailing: CGFloat(12)),
            ignoredEdgesForMargins: [],
            presentationLayout: PresentationLayout(horizontalLayout: .fill, verticalLayout: .automatic(alignment: .bottom)),
            animationBehavior: .present(edgeForAppearance: DirectionalViewEdge.bottom, edgeForDismissal: DirectionalViewEdge.bottom)
        )
    }
}
extension MessageView {
    public func configurePopup(title: String?, body: String?, backgoroundImageUrl: String?, imageUrl: String?, buttonTitle: String?, buttonTapHandler: ((_ button: UIButton) -> Void)?) {
        titleLabel?.text = title
        bodyLabel?.text = body
        backgroundContstraint?.constant = (screenWidth - 20) / 3
        if let backgroundUrl = URL(string: backgoroundImageUrl) {
            KingfisherManager.shared.retrieveImage(with: backgroundUrl) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let value):
                    self.backgroundImageView?.image = value.image
                case .failure(let error):
                    print(error.errorDescription ?? "")
                }
            }
        }
        if let imageUrl = URL(string: imageUrl) {
            KingfisherManager.shared.retrieveImage(with: imageUrl) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let value):
                    self.iconImageView?.image = value.image
                case .failure(let error):
                    print(error.errorDescription ?? "")
                }
            }
        }
        button?.setTitle(buttonTitle, for: .normal)
        self.buttonTapHandler = buttonTapHandler
        backgroundImageView?.isHidden = false
        iconLabel?.isHidden = true
    }
    
    public func configureDialog(title: String?, icon: UIImage?, buttonTitle: String?, secondButtonTitle: String?, buttonTapHandler: ((_ button: UIButton) -> Void)?, secondButtonTapHandler: ((_ button: UIButton) -> Void)?) {
        backgroundColor = .clear
        titleLabel?.text = title
        iconImageView?.image = icon
        button?.setTitle(buttonTitle, for: .normal)
        secondButton?.setTitle(secondButtonTitle, for: .normal)
        self.buttonTapHandler = buttonTapHandler
        self.secondButtonTapHandler = secondButtonTapHandler
    }
    
    public func configureTextView(title: String?, buttonTitle: String?, buttonTapHandler: ((_ button: UIButton) -> Void)?) {
        backgroundColor = .clear
        titleLabel?.text = title
        textView?.drawBorder(10, width: 0.5, color: UIColor.black.withAlphaComponent(0.12))
        textView?.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .color(from: 0x2C2D2E) : .color(from: 0xF2F3F5)
        button?.setTitle(buttonTitle, for: .normal)
        self.buttonTapHandler = buttonTapHandler
    }
}
extension Collection {
    public func to(index: Self.Index) -> Element? {
        guard index <= (count - 1 as! Self.Index) else { return nil }
        return self[index]
    }
    
    public var middle: Element? {
        get {
            return count / 2 > 0 ? self[count / 2 as! Self.Index] : self[0 as! Self.Index]
        }
    }
}
public class CollectionViewFooterView: UICollectionReusableView {
    lazy var footerView = FooterView(frame: CGRect(origin: .zero, size: .custom(screenWidth, 44)))

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(footerView)
        footerView.autoPinEdgesToSuperviewEdges()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension UIView {
    func fadeTransition(_ duration: CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
            CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.fade
        animation.duration = duration
        layer.add(animation, forKey: CATransitionType.fade.rawValue)
    }
}
