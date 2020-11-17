//
//  TableHeader.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 15.11.2020.
//

import UIKit
import Material

enum DividerVisibility {
    case visible
    case invisible
    
    static func getVisibility(_ value: Bool) -> Self {
        switch value {
        case true:
            return .visible
        case false:
            return .invisible
        }
    }
    
    static func setVisibility(_ value: Self) -> Bool {
        switch value {
        case .visible:
            return false
        case .invisible:
            return true
        }
    }
}

class TableHeader: View {
    @IBOutlet var headerView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        Bundle.main.loadNibNamed("TableHeader", owner: self, options: nil)
        addSubview(headerView)
        headerView.frame = bounds
        
        headerLabel.font = GoogleSansFont.semibold(with: 14)
        headerLabel.textColor = .adaptableDarkGrayVK
        
        dividerAlignment = .top
        dividerThickness = 0.4
        dividerColor = .adaptableDivider
    }
    
    open var headerTitle: String? {
        get { return headerLabel.text }
        set { headerLabel.text = newValue }
    }
    
    open var dividerVisibility: DividerVisibility {
        get { return DividerVisibility.getVisibility(isDividerHidden) }
        set { isDividerHidden = DividerVisibility.setVisibility(newValue) }
    }
}
