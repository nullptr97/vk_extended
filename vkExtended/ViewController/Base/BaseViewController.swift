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
    public let appBarViewController = MDCAppBarViewController()
    
    open var mainQueue = DispatchQueue.main
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
      super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        self.addChild(appBarViewController)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        view.addSubview(appBarViewController.view)
        appBarViewController.didMove(toParent: self)
        setupUI()
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupUI()
    }
    
    func setNavigationItems(leftNavigationItems: [UIBarButtonItem] = [], rightNavigationItems: [UIBarButtonItem] = []) {
        appBarViewController.navigationBar.leftBarButtonItems = leftNavigationItems
        appBarViewController.navigationBar.rightBarButtonItems = rightNavigationItems
    }
    
    // Настройка интерфейса
    func setupUI() {
        view.backgroundColor = .getThemeableColor(from: .white)
        
        appBarViewController.headerView.backgroundColor = .getThemeableColor(from: .white)
        appBarViewController.navigationBar.titleTextColor = .getThemeableColor(from: .black)
        appBarViewController.navigationBar.leadingItemsSupplementBackButton = true
        appBarViewController.navigationBar.titleAlignment = .leading
        appBarViewController.navigationBar.titleFont = GoogleSansFont.heavy(with: 22)
        
        setNeedsStatusBarAppearanceUpdate()
    }
    
    // Инициализация меню
    func initialActionSheet(title: String, message: String, actions: [MDCActionSheetAction]) {
        let actionSheet = MDCActionSheetController()
        actionSheet.elevation = .modalActionSheet
        actionSheet.alwaysAlignTitleLeadingEdges = true
        actionSheet.backgroundColor = .adaptableWhite

        actionSheet.titleFont = GoogleSansFont.bold(with: 17)
        actionSheet.messageFont = GoogleSansFont.medium(with: 16)
        actionSheet.actionFont = GoogleSansFont.medium(with: 15)
        
        actionSheet.titleTextColor = .adaptableTextPrimaryColor
        actionSheet.messageTextColor = UIColor.adaptableTextPrimaryColor.withAlphaComponent(0.5)
        actionSheet.actionTextColor = .adaptableTextPrimaryColor
        actionSheet.actionTintColor = .adaptableTextPrimaryColor

        actionSheet.title = title
        actionSheet.message = message
        
        for action in actions {
            actionSheet.addAction(action)
        }
        present(actionSheet, animated: true, completion: nil)
    }
}
