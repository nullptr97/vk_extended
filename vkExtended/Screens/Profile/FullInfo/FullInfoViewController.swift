//
//  FullInfoViewController.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 25.11.2020.
//

import UIKit
import Material
import SwiftyXML
import Alamofire

class FullInfoViewController: UIViewController {
    
    private var toolbar: Toolbar = Toolbar(frame: CGRect(origin: .zero, size: CGSize(width: screenWidth, height: 56)))
    var statusImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    var statusLabel: UILabel = {
        let label = UILabel()
        label.font = GoogleSansFont.semibold(with: 18)
        label.textColor = .getThemeableColor(fromNormalColor: .black)
        label.textAlignment = .center
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .getThemeableColor(fromNormalColor: .white)
        
//        prepareToolbar()
//        setupToolbar(title: "Подробная информация", subtitle: "")
        
        view.addSubview(statusImageView)
        statusImageView.autoPinEdge(.top, to: .top, of: view, withOffset: 24)
        statusImageView.autoAlignAxis(toSuperviewAxis: .vertical)
        statusImageView.autoSetDimensions(to: .identity(80))
        
        view.addSubview(statusLabel)
        statusLabel.autoPinEdge(.top, to: .bottom, of: statusImageView, withOffset: 16)
        statusLabel.autoPinEdge(.leading, to: .leading, of: view, withOffset: 16)
        statusLabel.autoPinEdge(.trailing, to: .trailing, of: view, withOffset: -16)
        statusLabel.autoPinEdge(.bottom, to: .bottom, of: view, withOffset: -24)
        
        preferredContentSize = .custom(screenWidth, 142 + (statusLabel.text?.height(with: screenWidth, font: GoogleSansFont.semibold(with: 18)) ?? 0))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // Подготовка тулбара
    func prepareToolbar() {
        self.view.addSubview(toolbar)
        toolbar.autoPinEdge(.top, to: .top, of: view, withOffset: 0)
        toolbar.autoPinEdge(.leading, to: .leading, of: view, withOffset: 0)
        toolbar.autoPinEdge(.trailing, to: .trailing, of: view, withOffset: 0)
        toolbar.autoSetDimension(.height, toSize: 56)
        toolbar.backgroundColor = .getThemeableColor(fromNormalColor: .white)
        
        toolbar.titleLabel.font = GoogleSansFont.bold(with: 20)
        toolbar.titleLabel.textColor = .getThemeableColor(fromNormalColor: .black)
    }
    
    // Настройка тулбара
    func setupToolbar(title: String, subtitle: String, leftViews: [UIView]? = nil, rightViews: [UIView]? = nil) {
        toolbar.title = title
        toolbar.detail = subtitle
        if let leftViews = leftViews {
            toolbar.leftViews = leftViews
        }
        if let rightViews = rightViews {
            toolbar.rightViews = rightViews
        }
    }
}
