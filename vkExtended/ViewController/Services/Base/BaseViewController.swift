//
//  BaseViewController.swift
//  ExtendedKit
//
//  Created by Ярослав Стрельников on 19.10.2020.
//

import UIKit
import MaterialComponents
import Material
import PromiseKit
import SwiftyJSON
import Alamofire
import SwiftMessages
import DRPLoadingSpinner

struct Note: Decodable {
    var id: Int
    var ownerId: Int
    var title: String
    var text: String
    var date: Int
    var comments: Int
    var readComments: Int
    var viewUrl: String
}

open class BaseViewController: UIViewController {
    public let statusView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        return view
    }()
    public let nativeSearchController = UISearchController(searchResultsController: nil)

    open var navigationTitle: String? {
        get { return navigationItem.titleLabel.text }
        set { navigationItem.titleLabel.text = newValue }
    }
    
    open var navigationSubtitle: String? {
        get { return navigationItem.detailLabel.text }
        set { navigationItem.detailLabel.text = newValue }
    }
    public lazy var refreshControl = DRPRefreshControl()
    
    open var mainQueue = DispatchQueue.main
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = []
        definesPresentationContext = true
        setupUI()
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupUI()
    }
    
    func setNavigationItems(leftNavigationItems: [UIButton] = [], rightNavigationItems: [UIButton] = []) {
        navigationItem.leftViews = leftNavigationItems
        navigationItem.rightViews = rightNavigationItems
    }
    
    // Настройка интерфейса
    func setupUI() {
        view.backgroundColor = .getThemeableColor(fromNormalColor: .white)
        
        refreshControl.loadingSpinner.colorSequence = [.getThemeableColor(fromNormalColor: .darkGray)]
        
        navigationItem.titleLabel.textColor = .getThemeableColor(fromNormalColor: .black)
        navigationItem.titleLabel.font = GoogleSansFont.bold(with: 20)
        
        navigationItem.titleLabel.adjustsFontSizeToFitWidth = true
        navigationItem.titleLabel.allowsDefaultTighteningForTruncation = true
        
        navigationItem.detailLabel.textColor = .getThemeableColor(fromNormalColor: .darkGray)
        navigationItem.detailLabel.font = GoogleSansFont.medium(with: 15)
        
        navigationItem.detailLabel.adjustsFontSizeToFitWidth = true
        navigationItem.detailLabel.allowsDefaultTighteningForTruncation = true

        setNeedsStatusBarAppearanceUpdate()
    }
    
    // Настройка статус окна
    func setupStatusView() {
        view.addSubview(statusView)
        view.bringSubviewToFront(statusView)
        statusView.autoPinEdge(.top, to: .top, of: view)
        statusView.autoPinEdge(.leading, to: .leading, of: view)
        statusView.autoPinEdge(.trailing, to: .trailing, of: view)
        statusView.autoPinEdge(.bottom, to: .bottom, of: view)
    }
    
    // Инициализация меню
    func initialActionSheet(title: String?, message: String?, actions: [MDCActionSheetAction]) {
        let actionSheet = MDCActionSheetController()
        actionSheet.elevation = .modalActionSheet
        actionSheet.alwaysAlignTitleLeadingEdges = true
        actionSheet.backgroundColor = .getThemeableColor(fromNormalColor: .white)

        actionSheet.titleFont = GoogleSansFont.bold(with: 17)
        actionSheet.messageFont = GoogleSansFont.medium(with: 16)
        actionSheet.actionFont = GoogleSansFont.medium(with: 15)
        
        actionSheet.titleTextColor = .adaptableTextPrimaryColor
        actionSheet.messageTextColor = UIColor.adaptableTextPrimaryColor.withAlphaComponent(0.5)
        actionSheet.actionTextColor = .adaptableTextPrimaryColor
        actionSheet.actionTintColor = .getAccentColor(fromType: .common)

        actionSheet.title = title
        actionSheet.message = message
        
        for action in actions {
            actionSheet.addAction(action)
        }
        if #available(iOS 13.0, *) {
            HapticFeedback.impact(.rigid).generateFeedback()
        } else {
            HapticFeedback.impact(.light).generateFeedback()
        }
        present(actionSheet, animated: true, completion: nil)
    }
    
    // Событие
    func event(message: String, isError: Bool) {
        let status2 = MessageView.viewFromNib(layout: .statusLine)
        status2.backgroundView.backgroundColor = !isError ? .extendedGreen : .extendedBackgroundRed
        status2.bodyLabel?.textColor = .white
        status2.configureContent(body: message)
        var status2Config = SwiftMessages.defaultConfig
        status2Config.presentationContext = .view(statusView)
        status2Config.preferredStatusBarStyle = .lightContent
        
        HapticFeedback.notification(!isError ? .success : .error).generateFeedback()
        SwiftMessages.show(config: status2Config, view: status2)
    }
}
