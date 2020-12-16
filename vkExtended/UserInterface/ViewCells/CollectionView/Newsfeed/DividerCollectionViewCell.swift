//
//  DividerCollectionViewCell.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 21.11.2020.
//

import UIKit
import IGListKit

class DividerCollectionViewCell: UICollectionViewCell, ListBindable {

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .getThemeableColor(fromNormalColor: .lightGray)
    }

    func bindViewModel(_ viewModel: Any) {
        return
    }
}
