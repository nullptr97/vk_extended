//
//  MiniAppViewController.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 16.12.2020.
//

import UIKit
import WebKit

class MiniAppViewController: UIViewController {
    var webView = WKWebView()
    let url: URL
    
    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(webView)
        webView.autoPinEdgesToSuperviewEdges()
        webView.load(URLRequest(url: url))
    }
}
extension MiniAppViewController: WKNavigationDelegate {
    
}
