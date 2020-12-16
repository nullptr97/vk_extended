//
//  CaptchaView.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 29.11.2020.
//

import UIKit

class CaptchaView: UIView {

    @IBOutlet var captchaView: UIView!
    @IBOutlet weak var contentView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var captchaImageView: UIImageView!
    @IBOutlet weak var confrimButton: UIButton!
    @IBOutlet weak var authDataTextField: UITextField!
    
    @IBOutlet weak var captchaImgHeight: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        Bundle.main.loadNibNamed("CaptchaView", owner: self, options: nil)
        addSubview(captchaView)
        captchaView.frame = bounds
        captchaView.backgroundColor = .getThemeableColor(fromNormalColor: .white)
        
        titleLabel.font = GoogleSansFont.semibold(with: 16)
        titleLabel.textColor = .getThemeableColor(fromNormalColor: .black)
        
        confrimButton.setCorners(radius: 12)
        confrimButton.titleLabel?.font = GoogleSansFont.bold(with: 16)
        confrimButton.backgroundColor = .getAccentColor(fromType: .common)
        
        authDataTextField.font = GoogleSansFont.regular(with: 15)
        authDataTextField.keyboardType = .default
    }
}
