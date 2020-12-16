//
//  UISettingsTableViewCell.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 26.11.2020.
//

import UIKit

enum UISetType: String {
    case icon = "Альтернативная иконка"
    case amoledTheme = "Amoled тема"
}

class UISettingsTableViewCell: UITableViewCell {
    @IBOutlet weak var settingsImageView: UIImageView! {
        didSet {
            settingsImageView.setCorners(radius: 12)
        }
    }
    @IBOutlet weak var settingsLabel: UILabel!
    @IBOutlet weak var settingsStateSwitch: UISwitch!
    
    weak var delegate: MenuCellDelegate?
    var cellType: UISetType = .icon
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .getThemeableColor(fromNormalColor: .white)
        contentView.backgroundColor = .getThemeableColor(fromNormalColor: .white)
        
        settingsLabel.font = GoogleSansFont.medium(with: 16)
        settingsStateSwitch.onTintColor = .getAccentColor(fromType: .common)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setState(_ state: Bool) {
        settingsStateSwitch.isOn = !state
    }

    @IBAction func onChangeState(_ sender: UISwitch) {
        delegate?.onChangeSwitchState(for: self, state: !sender.isOn)
    }
}
