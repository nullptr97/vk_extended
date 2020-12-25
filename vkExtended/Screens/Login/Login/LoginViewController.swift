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
import SwiftMessages

class LoginViewController: UIViewController {
    @IBOutlet weak var authView: UIView!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var authButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var registerImageView: UIImageView!
    
    private let keyboardManagerService = KeyboardManagerService()
    private let requestQueue = DispatchQueue(label: "requestQueue", qos: .background, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
    private let mainQueue = DispatchQueue.main
    private let userDefaults = UserDefaults.standard
    private var vkDelegate: ExtendedVKDelegate?
    
    private var isInitialLayout: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(onCaptchaInputed(notification:)), name: .onCaptchaDone, object: nil)
        
        view.backgroundColor = .getThemeableColor(fromNormalColor: .white)
        
        authView.drawBorder(12, width: 0.5, color: UIColor.black.withAlphaComponent(0.12))
        authView.backgroundColor = .adaptableField
        
        authButton.setCorners(radius: 12)
        authButton.titleLabel?.font = GoogleSansFont.bold(with: 16)
        authButton.setTitleColor(.getThemeableColor(fromNormalColor: .white), for: .normal)
        authButton.backgroundColor = .getAccentColor(fromType: .common)
        authButton.isEnabled = false
        authButton.alpha = 0.5

        registerButton.drawBorder(12, width: 0.5, color: .getThemeableColor(fromNormalColor: .lightGray))
        registerButton.backgroundColor = .clear
        registerButton.setTitleColor(.getThemeableColor(fromNormalColor: .black), for: .normal)
        registerButton.titleLabel?.font = GoogleSansFont.bold(with: 16)
        
        registerImageView.image = UIImage(named: "edit_outline_28")?.withRenderingMode(.alwaysTemplate).tint(with: .getThemeableColor(fromNormalColor: .black))
        
        loginTextField.font = GoogleSansFont.regular(with: 15)
        loginTextField.backgroundColor = .clear
        loginTextField.keyboardType = .emailAddress
        loginTextField.delegate = self
        
        passwordTextField.font = GoogleSansFont.regular(with: 15)
        passwordTextField.backgroundColor = .clear
        passwordTextField.keyboardType = .default
        passwordTextField.delegate = self
        
        dividerView.backgroundColor = UIColor.black.withAlphaComponent(0.12)
        Self.activityIndicator.startAnimating()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if isInitialLayout {
            defer {
                isInitialLayout = false
            }
            keyboardManagerService.animateWhenKeyboardAppear = { [weak self] appearPostIndex, keyboardHeight, keyboardHeightIncrement in
                if let self = self {
                    self.view.transform = CGAffineTransform.identity.translatedBy(x: 0, y: -48)
                }
            }
            keyboardManagerService.animateWhenKeyboardDisappear = { [weak self] keyboardHeight in
                if let self = self {
                    self.view.transform = .identity
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    func auth(isNeedCaptchaData: Bool = false, captchaSid: String? = nil, captchaKey: String? = nil) {
        let loadingNotification = MBProgressHUD.showAdded(to: view, animated: true)
        guard let login = loginTextField.text, let password = passwordTextField.text, !login.isEmpty, !password.isEmpty else { return }
        mainQueue.async {
            loadingNotification.mode = .customView
            loadingNotification.customView = Self.activityIndicator
            loadingNotification.label.font = GoogleSansFont.semibold(with: 14)
            loadingNotification.label.textColor = .getThemeableColor(fromNormalColor: .darkGray)
            loadingNotification.label.text = "Авторизация"
        }
        
        if let captchaKey = captchaKey, let captchaSid = captchaSid {
            VK.sessions.default.logIn(login: login, password: password, captchaSid: captchaSid, captchaKey: captchaKey) { [weak self] in
                guard let self = self else { return }
                self.observeSuccess(with: loadingNotification)
            } onError: { [weak self] (error) in
                guard let self = self else { return }
                self.observeError(error: error, with: loadingNotification)
            }
            return
        }
        
        VK.sessions.default.logIn(login: login, password: password) { [weak self] in
            guard let self = self else { return }
            self.observeSuccess(with: loadingNotification)
        } onError: { [weak self] (error) in
            guard let self = self else { return }
            self.observeError(error: error, with: loadingNotification)
        }
    }
    
    func observeSuccess(with loadingNotification: MBProgressHUD) {
        self.mainQueue.async {
            loadingNotification.label.text = "Успешный вход"
            UIView.animate(.promise, duration: 0.3, delay: 0, options: [.preferredFramesPerSecond60]) {
                loadingNotification.layoutIfNeeded()
            }
            loadingNotification.customView = Self.doneIndicator
            Self.doneIndicator.play()
            loadingNotification.hide(animated: true, afterDelay: 1)
            self.mainQueue.asyncAfter(deadline: .now() + 1) {
                self.postNotification(name: .onLogin)
                guard let window = self.view.window else { return }
                
                UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromRight) {
                    window.rootViewController = FullScreenNavigationController(rootViewController: BottomNavigationViewController())
                }
            }
        }
    }
    
    func observeError(error: VKError, isNeedCaptchaData: Bool = false, with loadingNotification: MBProgressHUD) {
        guard let login = loginTextField.text, let password = passwordTextField.text, !login.isEmpty, !password.isEmpty else { return }
        mainQueue.async {
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
            case .needValidation(validationType: let type, phoneMask: let mask):
                guard let login = self.loginTextField.text, let password = self.passwordTextField.text, !login.isEmpty, !password.isEmpty else { return }
                self.navigationController?.pushViewController(ValidationViewController(login: login, password: password, phoneMask: mask), animated: true)
            default:
                guard let message = error.toApi()?.message else { return }
                self.mainQueue.async {
                    loadingNotification.label.text = message
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
    
    @objc func onCaptchaInputed(notification: Notification) {
        guard let captchaData = notification.userInfo?["captchaData"] as? [String] else { return }
        auth(isNeedCaptchaData: true, captchaSid: captchaData.first, captchaKey: captchaData.last)
    }
    
    @IBAction func authAction(_ sender: UIButton) {
        auth(isNeedCaptchaData: false)
    }
}
extension LoginViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if passwordTextField.isEmpty || loginTextField.isEmpty {
            authButton.isEnabled = false
            authButton.alpha = 0.5
        } else {
            authButton.isEnabled = true
            authButton.alpha = 1
        }
    }
}
