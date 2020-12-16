//
//  MenuTableViewCell.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 15.11.2020.
//

import UIKit
import Material

enum CellType: String, CaseIterable {
    case audio = "Музыка"
    case groups = "Сообщества"
    case videos = "Видео"
    case files = "Файлы"
    case bookmarks = "Закладки"
    case liked = "Понравившееся"
    case ui = "Интерфейс"
    case messages = "Сообщения"
    case newsfeed = "Новости"
    case dev = "Для разработчика"
    case logout = "Выйти из аккаунта"
}

protocol MenuCellDelegate: class {
    func onOpenMenuItem(for cell: MenuTableViewCell)
    func onChangeSwitchState(for cell: UISettingsTableViewCell, state: Bool)
}

class MenuTableViewCell: TableViewCell {
    @IBOutlet weak var menuItemLabel: UILabel!
    @IBOutlet weak var menuItemImageView: UIImageView!
    
    weak var delegate: MenuCellDelegate?
    var cellType: CellType = .audio
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .getThemeableColor(fromNormalColor: .white)
        contentView.backgroundColor = .getThemeableColor(fromNormalColor: .white)
        
        menuItemLabel.font = GoogleSansFont.medium(with: 16)
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapMenuItem)))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @objc func onTapMenuItem() {
        delegate?.onOpenMenuItem(for: self)
    }
    
    var itemTitle: String? {
        get { return menuItemLabel.text }
        set { menuItemLabel.text = newValue }
    }
    
    var itemImage: UIImage? {
        get { return menuItemImageView.image }
        set { menuItemImageView.image = newValue?.withRenderingMode(.alwaysTemplate).tint(with: .getAccentColor(fromType: .common)) }
    }
    
    var itemImageTint: UIColor {
        get { return menuItemImageView.image?.averageColor ?? .clear }
        set { menuItemImageView.image = menuItemImageView.image?.withRenderingMode(.alwaysTemplate).tint(with: newValue) }
    }
    
    var itemTitleTint: UIColor {
        get { return menuItemLabel.textColor }
        set { menuItemLabel.textColor = newValue }
    }
}
