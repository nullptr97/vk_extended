//
//  BaseTabsViewController.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 03.12.2020.
//

import UIKit
import Material
import MaterialComponents
import SwiftMessages

class BaseTabsViewController: TabsController {
    public let statusView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        return view
    }()
    var toolbar: Toolbar = Toolbar(frame: CGRect(origin: .zero, size: CGSize(width: Screen.bounds.width, height: 56)))

    override init(viewControllers: [UIViewController], selectedIndex: Int = 0) {
        super.init(viewControllers: viewControllers, selectedIndex: selectedIndex)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open var navigationTitle: String? {
        get { return navigationItem.titleLabel.text }
        set { navigationItem.titleLabel.text = newValue }
    }
    
    open var navigationSubtitle: String? {
        get { return navigationItem.detailLabel.text }
        set { navigationItem.detailLabel.text = newValue }
    }
    
    var toolbarTitle: String? {
        get { return toolbar.title }
        set { toolbar.title = newValue }
    }
    
    var toolbarSubtitle: String? {
        get { return toolbar.detail }
        set { toolbar.detail = newValue }
    }
    
    override func prepare() {
        super.prepare()
//        tabBar.frame.size.width = toolbar.centerViews.first?.bounds.width ?? 0
        tabBarAlignment = .bottom
        tabBar.backgroundColor = .getThemeableColor(fromNormalColor: .white)
        tabBar.dividerColor = .clear
        tabBar.lineHeight = 2
        tabBar.setLineColor(.getAccentColor(fromType: .common), for: .selected)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        edgesForExtendedLayout = []
        definesPresentationContext = true
        
//        prepareToolbar(fonts: [GoogleSansFont.bold(with: 21), GoogleSansFont.regular(with: 13)])
//        setupToolbar(title: "", subtitle: "", leftViews: [], rightViews: [])
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
        navigationItem.titleLabel.textColor = .getThemeableColor(fromNormalColor: .black)
        navigationItem.titleLabel.font = GoogleSansFont.bold(with: 21)
        
        
        
//        toolbar.centerViews = [tabBar]
        
        view.backgroundColor = .getThemeableColor(fromNormalColor: .white)
        
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
    
    // Подготовка тулбара
    func prepareToolbar(fonts: [UIFont]) {
        self.view.addSubview(toolbar)
        toolbar.autoPinEdge(toSuperviewSafeArea: .top, withInset: 12)
        toolbar.autoPinEdge(toSuperviewSafeArea: .trailing, withInset: 16)
        toolbar.autoPinEdge(toSuperviewSafeArea: .leading, withInset: 16)
        toolbar.autoSetDimension(.height, toSize: 56)
        toolbar.backgroundColor = .getThemeableColor(fromNormalColor: .white)
    }
    
    // Настройка тулбара
    func setupToolbar(title: String, subtitle: String, leftViews: [UIView]?, rightViews: [UIView]?) {
        toolbar.title = title
        toolbar.detail = subtitle
        if let leftViews = leftViews {
            toolbar.leftViews = leftViews
        }
        if let rightViews = rightViews {
            toolbar.rightViews = rightViews
        }
    }
    
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
