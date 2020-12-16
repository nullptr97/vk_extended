//
//  NewsfeedTextCollectionViewCell.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 21.11.2020.
//

import UIKit
import Material
import IGListKit

class NewsfeedTextCollectionViewCell: CollectionViewCell, ListBindable {
    @IBOutlet weak var newsTextView: UITextView!
    @IBOutlet weak var revealPostButton: UIButton!
    @IBOutlet weak var revealConstraint: NSLayoutConstraint!
    
    weak var delegate: NewsFeedCellDelegate?
        
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .getThemeableColor(fromNormalColor: .white)
        
        newsTextView.font = GoogleSansFont.regular(with: 15)
        newsTextView.textColor = .getThemeableColor(fromNormalColor: .black)
        newsTextView.textContainer.lineFragmentPadding = 0
        newsTextView.textContainerInset = .zero
    }

    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? NewsfeedTextViewModel else { return }
        revealPostButton.isHidden = viewModel.isReveal
        newsTextView.text = viewModel.text
        newsTextView.sizeToFit()
        revealConstraint.constant = viewModel.isReveal ? 0 : 24
    }

    @IBAction func onRevealPost(_ sender: Any) {
        delegate?.revealPost(for: self)
    }
}
