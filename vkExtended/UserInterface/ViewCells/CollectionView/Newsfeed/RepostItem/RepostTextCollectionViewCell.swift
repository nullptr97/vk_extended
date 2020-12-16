//
//  RepostTextCollectionViewCell.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 24.11.2020.
//

import UIKit
import IGListKit

class RepostTextCollectionViewCell: UICollectionViewCell, ListBindable {
    @IBOutlet weak var repostTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .getThemeableColor(fromNormalColor: .white)

        repostTextView.font = GoogleSansFont.regular(with: 15)
        repostTextView.textColor = .getThemeableColor(fromNormalColor: .black)
        repostTextView.textContainer.lineFragmentPadding = 0
        repostTextView.textContainerInset = .zero
    }
    
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? RepostTextViewModel else { return }
        repostTextView.text = viewModel.text
        
        repostTextView.sizeToFit()
    }
}
