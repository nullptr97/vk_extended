//
//  FooterView.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 26.10.2020.
//

import Foundation
import UIKit
import MaterialComponents
import PureLayout

class FooterView: UIView {
    private var counterLabel: UILabel = {
       let label = UILabel()
        label.font = GoogleSansFont.medium(with: 13)
        label.textColor = .getThemeableColor(fromNormalColor: .darkGray)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var activityIndicator: MDCActivityIndicator = {
        let activityIndicator = MDCActivityIndicator()
        activityIndicator.radius = 12
        activityIndicator.strokeWidth = 2.5
        activityIndicator.indicatorMode = .indeterminate
        activityIndicator.cycleColors = [.adaptableDarkGrayVK]
        return activityIndicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // autoSetDimensions(to: frame.size)

        counterLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(counterLabel)
        addSubview(activityIndicator)

        counterLabel.autoCenterInSuperview()
    
        activityIndicator.autoCenterInSuperview()
        
        stopActivityIndicator
    }
    
    var footerTitle: String? {
        get {
            return counterLabel.text ?? ""
        } set {
            if newValue != nil {
                stopActivityIndicator
            } else {
                startActivityIndicator
            }
            counterLabel.text = newValue
        }
    }
    
    var startActivityIndicator: Void {
        activityIndicator.startAnimating()
    }
    
    var stopActivityIndicator: Void {
        activityIndicator.stopAnimating()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
