//
//  NewsfeedEventAttachmentsCollectionViewCell.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 27.11.2020.
//

import UIKit
import IGListKit

class NewsfeedEventAttachmentsCollectionViewCell: UICollectionViewCell, ListBindable {
    @IBOutlet weak var eventView: UIView!
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var isFavoriteButton: UIButton!
    @IBOutlet weak var eventTimeLabel: UILabel!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var membersLabel: UILabel!
    @IBOutlet weak var gotoButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        eventView.backgroundColor = .getThemeableColor(fromNormalColor: .white)
        eventView.drawBorder(12, width: 0.4, color: .adaptableDivider, isOnlyTopCorners: false)
        
        eventImageView.setRounded()
        
        eventTimeLabel.font = GoogleSansFont.medium(with: 11)
        eventTimeLabel.textColor = .getAccentColor(fromType: .common)
        
        eventNameLabel.font = GoogleSansFont.bold(with: 15)
        eventNameLabel.textColor = .getThemeableColor(fromNormalColor: .black)
        
        membersLabel.font = GoogleSansFont.regular(with: 12)
        membersLabel.textColor = .getThemeableColor(fromNormalColor: .darkGray)
    }

    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? NewsfeedEventAttachmentsViewModel, let event = viewModel.eventAttachements.first else { return }
        
        eventImageView.kf.setImage(with: URL(string: event.eventImageUrl))
        
        let date = Date(timeIntervalSince1970: event.time.double)
        let dateTitle = StdService.instance.postDate(with: date).string(from: date)
        
        gotoButton.backgroundColor = event.memberStatus == 1 ? .clear : .getAccentColor(fromType: .common)
        gotoButton.setTitle(event.memberStatus == 1 ? "" : "Пойду", for: .normal)
        gotoButton.setImage(event.memberStatus == 1 ? UIImage(named: "done_16") : nil, for: .normal)
        
        eventTimeLabel.text = dateTitle.uppercased()
        
        eventNameLabel.text = event.eventName
        
        membersLabel.text = event.text
        
        eventTimeLabel.sizeToFit()
        eventNameLabel.sizeToFit()
        membersLabel.sizeToFit()
    }
}
