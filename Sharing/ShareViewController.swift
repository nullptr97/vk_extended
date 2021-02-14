//
//  ShareViewController.swift
//  Sharing
//
//  Created by Ярослав Стрельников on 11.01.2021.
//

import UIKit
import Social
import Material

class ShareViewController: UIViewController {
    private let toolbar = Toolbar(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: 52)))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(toolbar)
        toolbar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        
        toolbar.title = "Поделиться"
    }

}
