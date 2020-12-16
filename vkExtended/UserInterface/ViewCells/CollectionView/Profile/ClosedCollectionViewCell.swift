//
//  ClosedOrBannedCollectionViewCell.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 25.11.2020.
//

import UIKit
import IGListKit

class ClosedCollectionViewCell: UICollectionViewCell, ListBindable {
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var closeImageView: UIImageView!
    @IBOutlet weak var causeOfBanTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .getThemeableColor(fromNormalColor: .white)
        
        infoView.drawBorder(12, width: 0.5, color: .adaptableDivider, isOnlyTopCorners: false)
        infoView.backgroundColor = .getThemeableColor(fromNormalColor: .lightGray)
        
        causeOfBanTextView.textContainer.lineFragmentPadding = 0
        causeOfBanTextView.textContainerInset = .zero
    }

    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? CloseInfoViewModel else { return }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3
        let attributedCloseText = NSAttributedString(string: viewModel.causeText, attributes: [.font: GoogleSansFont.bold(with: 16), .foregroundColor: UIColor.getThemeableColor(fromNormalColor: .black), .paragraphStyle: paragraphStyle]) + attributedNewLine + NSAttributedString(string: viewModel.causeRecomendationText, attributes: [.font: GoogleSansFont.medium(with: 14), .foregroundColor: UIColor.getThemeableColor(fromNormalColor: .darkGray)])
        causeOfBanTextView.attributedText = attributedCloseText
        causeOfBanTextView.sizeToFit()
        closeImageView.image = UIImage(named: "lock_outline_56")?.withRenderingMode(.alwaysTemplate).tint(with: .getThemeableColor(fromNormalColor: .darkGray))
    }
}
