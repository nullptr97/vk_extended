//
//  LoginViewController.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 19.10.2020.
//

import UIKit
import RealmSwift
import PromiseKit
import MBProgressHUD
import Lottie
import MaterialComponents

class LoginViewController: UIViewController {
    @IBOutlet weak var authView: UIView!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var authButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var registerImageView: UIImageView!
    
    private let requestQueue = DispatchQueue(label: "requestQueue", qos: .background, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
    private let mainQueue = DispatchQueue.main
    
    private let userDefaults = UserDefaults.standard
    
    private var vkDelegate: ExtendedVKDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(onCaptchaInputed(notification:)), name: .onCaptchaDone, object: nil)
        
        view.backgroundColor = .getThemeableColor(from: .white)
        
        authView.drawBorder(12, width: 0.5, color: .adaptableDivider)
        authView.backgroundColor = .adaptablePostColor
        
        authButton.setCorners(radius: 12)
        authButton.titleLabel?.font = GoogleSansFont.bold(with: 16)
        authButton.backgroundColor = .systemBlue
        
        registerButton.drawBorder(12, width: 0.5, color: .adaptableDivider)
        registerButton.backgroundColor = .clear
        registerButton.setTitleColor(.getThemeableColor(from: .black), for: .normal)
        registerButton.titleLabel?.font = GoogleSansFont.bold(with: 16)
        
        registerImageView.image = UIImage(named: "edit_outline_28")?.withRenderingMode(.alwaysTemplate).tint(with: .getThemeableColor(from: .black))
        
        loginTextField.font = GoogleSansFont.regular(with: 15)
        loginTextField.keyboardType = .emailAddress
        
        passwordTextField.font = GoogleSansFont.regular(with: 15)
        passwordTextField.keyboardType = .default
        
        dividerView.backgroundColor = .adaptableDivider
        Self.activityIndicator.startAnimating()
    }
    
    func auth(isNeedCaptchaData: Bool = false, captchaSid: String? = nil, captchaKey: String? = nil) {
        let loadingNotification = MBProgressHUD.showAdded(to: view, animated: true)
        guard let login = loginTextField.text, let password = passwordTextField.text, !login.isEmpty, !password.isEmpty else { return }
        mainQueue.async {
            loadingNotification.mode = .customView
            loadingNotification.customView = Self.activityIndicator
            loadingNotification.label.font = GoogleSansFont.semibold(with: 14)
            loadingNotification.label.textColor = .adaptableDarkGrayVK
            loadingNotification.label.text = "Авторизация"
        }
        VK.sessions.default.logIn(login: login, password: password, captchaSid: captchaSid, captchaKey: captchaKey) { [weak self] in
            guard let self = self else { return }
            self.mainQueue.async {
                loadingNotification.label.text = "Успешный вход"
                UIView.animate(.promise, duration: 0.3, delay: 0, options: [.preferredFramesPerSecond60]) {
                    loadingNotification.layoutIfNeeded()
                }
                loadingNotification.customView = Self.doneIndicator
                Self.doneIndicator.play()
                loadingNotification.hide(animated: true, afterDelay: 1)
                self.mainQueue.asyncAfter(deadline: .now() + 1) {
                    self.navigationController?.pushViewController(BottomNavigationViewController(), animated: true)
                }
            }
        } onError: { [weak self] (error) in
            guard let self = self else { return }
            self.mainQueue.async {
                switch error {
                case .needCaptcha(captchaImg: let captchaImg, captchaSid: let captchaSid):
                    self.mainQueue.async {
                        if isNeedCaptchaData {
                            loadingNotification.label.text = "Неверная Captcha"
                            UIView.animate(.promise, duration: 0.3, delay: 0, options: [.preferredFramesPerSecond60]) {
                                loadingNotification.layoutIfNeeded()
                            }
                            loadingNotification.customView = Self.errorIndicator
                            Self.errorIndicator.play()
                            loadingNotification.hide(animated: true, afterDelay: 3)
                        } else {
                            let captchaController = CaptchaViewController(captchaUrl: captchaImg, captchaSid: captchaSid, login: login, password: password)
                            captchaController.modalPresentationStyle = .fullScreen
                            self.present(captchaController, animated: true, completion: nil)
                        }
                    }
                case .incorrectLoginPassword:
                    self.mainQueue.async {
                        loadingNotification.label.text = "Неверный логин или пароль"
                        UIView.animate(.promise, duration: 0.3, delay: 0, options: [.preferredFramesPerSecond60]) {
                            loadingNotification.layoutIfNeeded()
                        }
                        loadingNotification.customView = Self.errorIndicator
                        Self.errorIndicator.play()
                        loadingNotification.hide(animated: true, afterDelay: 3)
                    }
                default:
                    guard let message = error.toApi()?.message, let code = error.toApi()?.code else { return }
                    self.mainQueue.async {
                        loadingNotification.label.text = "\(message) (код \(code)"
                        UIView.animate(.promise, duration: 0.3, delay: 0, options: [.preferredFramesPerSecond60]) {
                            loadingNotification.layoutIfNeeded()
                        }
                        loadingNotification.customView = Self.errorIndicator
                        Self.errorIndicator.play()
                        loadingNotification.hide(animated: true, afterDelay: 3)
                    }
                }
            }
        }
    }
    
    @objc func onCaptchaInputed(notification: Notification) {
        guard let captchaData = notification.userInfo?["captchaData"] as? [String] else { return }
        auth(isNeedCaptchaData: true, captchaSid: captchaData.first, captchaKey: captchaData.last)
    }
    
    @IBAction func authAction(_ sender: UIButton) {
        auth(isNeedCaptchaData: false)
    }
}
