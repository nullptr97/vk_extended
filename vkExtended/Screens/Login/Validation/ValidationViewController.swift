//
//  ValidationViewController.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 29.11.2020.
//

import UIKit
import Alamofire

class ValidationViewController: UIViewController {
    let login: String
    let password: String
    let phoneMask: String
    
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var alternateAuthButton: UIButton!
    @IBOutlet weak var twoAuthCodeTextField: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var authButton: UIButton!
    
    let keyboardManagerService = KeyboardManagerService()
    var isInitialLayout = true
    
    var seconds = 150
    var timer = Timer()
    
    var isTimerRunning = false
    var resumeTapped = false
    
    init(login: String, password: String, phoneMask: String) {
        self.login = login
        self.password = password
        self.phoneMask = phoneMask
        super.init(nibName: "ValidationViewController", bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: false)
        twoAuthCodeTextField.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if isInitialLayout {
            defer {
                isInitialLayout = false
            }
            keyboardManagerService.animateWhenKeyboardAppear = { [weak self] appearPostIndex, keyboardHeight, keyboardHeightIncrement in
                if let self = self {
                    self.bottomConstraint.constant = -keyboardHeight + 16
                    self.view.layoutIfNeeded()
                }
            }
            keyboardManagerService.animateWhenKeyboardDisappear = { [weak self] keyboardHeight in
                if let self = self {
                    self.bottomConstraint.constant = -16
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    func setupUI() {
        stateLabel.textColor = .getThemeableColor(fromNormalColor: .darkGray)
        stateLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        twoAuthCodeTextField.setBorder(10, width: 0.75, color: .getThemeableColor(fromNormalColor: .lightGray))
        
        authButton.setCorners(radius: 12)
        authButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        authButton.backgroundColor = .getAccentColor(fromType: .common)
        
        alternateAuthButton.setCorners(radius: 12)
        alternateAuthButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        alternateAuthButton.backgroundColor = .getThemeableColor(fromNormalColor: .white)
        alternateAuthButton.setTitleColor(.getAccentColor(fromType: .common), for: .normal)
    }
    
    func auth(code: String? = nil, forceSms: Int? = nil) {
        if let code = code {
            VK.sessions.default.logIn(login: login, password: password, code: code.isEmpty ? " " : code, forceSms: forceSms) { [weak self] in
                guard let self = self else { return }
                self.observeSuccess()
                if forceSms == 1 {
                    let text = NSAttributedString(string: "Мы отправили SMS c кодом подтверждения на номер", attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .medium), .foregroundColor: UIColor.getThemeableColor(fromNormalColor: .darkGray)]) + attributedNewLine + NSAttributedString(string: self.phoneMask, attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .medium), .foregroundColor: UIColor.getThemeableColor(fromNormalColor: .black)])
                    
                    self.stateLabel.attributedText = text
                    self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
                    self.isTimerRunning = true
                }
            } onError: { [weak self] (error) in
                guard let self = self else { return }
                self.observeError(error: error)
            }
            return
        }
    }
    
    @objc func updateTimer() {
        if seconds < 1 {
            timer.invalidate()
            alternateAuthButton.setTitleColor(.getAccentColor(fromType: .common), for: .normal)
            alternateAuthButton.setTitle(TimeInterval(seconds).stringDuration, for: .normal)
        } else {
            seconds -= 1
            alternateAuthButton.setTitleColor(.getThemeableColor(fromNormalColor: .darkGray), for: .normal)
            alternateAuthButton.setTitle("Код придёт в течении \(TimeInterval(seconds).stringDuration)", for: .normal)
        }
    }
    
    func observeSuccess() {
        main.async {
            self.main.asyncAfter(deadline: .now() + 1) {
                self.postNotification(name: .onLogin)
                guard let window = self.view.window else { return }
                
                UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromRight) {
                    window.rootViewController = TabBarViewController()
                }
            }
        }
    }
    
    func observeError(error: VKError, isNeedCaptchaData: Bool = false) {
        main.async {
            switch error {
            case .needCaptcha(captchaImg: let captchaImg, captchaSid: let captchaSid):
                break
            case .needValidation(validationType: let type, phoneMask: let mask):
                self.twoAuthCodeTextField.setBorder(10, width: 0.75, color: .extendedBackgroundRed)
            default:
                break
            }
        }
    }
    
    @IBAction func onAuth(_ sender: Any) {
        guard let code = twoAuthCodeTextField.text else { return }
        auth(code: code, forceSms: 0)
    }
    
    @IBAction func onAlternateAuth(_ sender: Any) {
        guard let code = twoAuthCodeTextField.text else { return }
        auth(code: code, forceSms: 1)
    }
}
extension ValidationViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        twoAuthCodeTextField.setBorder(10, width: 0.75, color: .getAccentColor(fromType: .common))
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        authButton.isHidden = textField.text?.isEmpty ?? true || textField.text?.count ?? 0 < 6
        alternateAuthButton.isHidden = textField.text?.isEmpty ?? true ? false : textField.text?.count ?? 0 == 6
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        twoAuthCodeTextField.setBorder(10, width: 0.75, color: .getThemeableColor(fromNormalColor: .lightGray))
    }
}
