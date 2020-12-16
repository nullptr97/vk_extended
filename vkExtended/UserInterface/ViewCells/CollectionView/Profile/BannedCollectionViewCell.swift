//
//  BannedCollectionViewCell.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 29.11.2020.
//

import UIKit
import IGListKit

class BannedCollectionViewCell: UICollectionViewCell, ListBindable {
    @IBOutlet weak var causeBanLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        causeBanLabel.textColor = .getThemeableColor(fromNormalColor: .darkGray)
        causeBanLabel.font = GoogleSansFont.medium(with: 13)
    }

    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? BannedInfoViewModel else { return }
        causeBanLabel.text = viewModel.causeText
    }
}
