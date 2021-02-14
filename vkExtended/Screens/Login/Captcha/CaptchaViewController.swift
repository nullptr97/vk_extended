//
//  CaptchaViewController.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 24.10.2020.
//

import UIKit
import Kingfisher
import RealmSwift

class CaptchaViewController: UIViewController {
    @IBOutlet weak var capthcaImageView: UIImageView!
    @IBOutlet weak var captchaEnterTextField: UITextField!
    @IBOutlet weak var reauthButton: UIButton!
    
    var captchaSid: String
    var captchaImgUrl: String
    var login: String
    var password: String
    
    init(captchaUrl: String, captchaSid: String, login: String, password: String) {
        self.captchaSid = captchaSid
        self.login = login
        self.password = password
        self.captchaImgUrl = captchaUrl
        
        super.init(nibName: "CaptchaViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: false)

        reauthButton.setCorners(radius: 12)
        reauthButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        reauthButton.backgroundColor = .getAccentColor(fromType: .common)
        
        captchaEnterTextField.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        captchaEnterTextField.keyboardType = .default
        
        capthcaImageView.kf.setImage(with: URL(string: captchaImgUrl))
    }
    
    @IBAction func reAuthAction(_ sender: UIButton) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            let captchaData: [AnyHashable : [String]]? = ["captchaData" : [self.captchaSid, self.captchaEnterTextField.text ?? ""]]
            NotificationCenter.default.post(name: .onCaptchaDone, object: nil, userInfo: captchaData)
        }
    }
}
