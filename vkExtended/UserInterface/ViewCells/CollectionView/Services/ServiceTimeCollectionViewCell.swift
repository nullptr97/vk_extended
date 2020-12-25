//
//  ServiceTimeCollectionViewCell.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 16.12.2020.
//

import UIKit
import IGListKit

class ServiceTimeCollectionViewCell: UICollectionViewCell, ListBindable {
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    
    var isAnimated: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dayLabel.textColor = .getThemeableColor(fromNormalColor: .darkGray)
        monthLabel.textColor = .getAccentColor(fromType: .common)
        
        dayLabel.font = GoogleSansFont.semibold(with: 23)
        monthLabel.font = GoogleSansFont.semibold(with: 23)
    }

    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? ServiceDateViewModel else { return }
        let sinceStartOfDay = Date().timeIntervalSince(Date().startOfDay).int
        
        _ = viewModel.to?.enumerated().compactMap { (index, timeTo) in
            dayLabel.textColor = .getThemeableColor(fromNormalColor: .black)
            if sinceStartOfDay > (viewModel.from?[index] ?? 0) && sinceStartOfDay < timeTo {
                dayLabel.text = viewModel.welcomeText?[index]
                monthLabel.text = nil
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            UIView.transition(with: self, duration: 1, options: .transitionFlipFromTop) {
                self.dayLabel.text = viewModel.title
                self.monthLabel.text = viewModel.text
                
                self.dayLabel.textColor = .getThemeableColor(fromNormalColor: .darkGray)
            }
        }

        dayLabel.sizeToFit()
        monthLabel.sizeToFit()
    }
}
