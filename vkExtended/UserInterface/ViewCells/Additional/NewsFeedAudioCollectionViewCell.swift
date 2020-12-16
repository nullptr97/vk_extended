//
//  NewsFeedAudioCollectionViewCell.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 23.11.2020.
//

import UIKit
import Material

class NewsFeedAudioCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var playingButton: UIButton!
    @IBOutlet weak var audioTitleLabel: UILabel!
    @IBOutlet weak var audioAuthorLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        audioTitleLabel.textColor = .getThemeableColor(fromNormalColor: .black)
        audioTitleLabel.font = GoogleSansFont.medium(with: 16)
        
        audioAuthorLabel.textColor = .getThemeableColor(fromNormalColor: .darkGray)
        audioAuthorLabel.font = GoogleSansFont.regular(with: 13)
        
        durationLabel.textColor = .getThemeableColor(fromNormalColor: .darkGray)
        durationLabel.font = GoogleSansFont.regular(with: 13)
        
        playingButton.drawBorder(21, width: 1.5, color: .getAccentColor(fromType: .common), isOnlyTopCorners: false)
        playingButton.setImage(Icon.cm.play?.withRenderingMode(.alwaysTemplate).tint(with: .getAccentColor(fromType: .common)), for: .normal)
    }
}
