//
//  MenuTableViewCell.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 15.11.2020.
//

import UIKit
import Material

class MenuTableViewCell: TableViewCell {
    @IBOutlet weak var menuItemLabel: UILabel!
    @IBOutlet weak var menuItemImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        menuItemLabel.font = GoogleSansFont.medium(with: 16)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var itemTitle: String? {
        get { return menuItemLabel.text }
        set { menuItemLabel.text = newValue }
    }
    
    var itemImage: UIImage? {
        get { return menuItemImageView.image }
        set { menuItemImageView.image = newValue?.withRenderingMode(.alwaysTemplate).tint(with: .systemBlue) }
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
