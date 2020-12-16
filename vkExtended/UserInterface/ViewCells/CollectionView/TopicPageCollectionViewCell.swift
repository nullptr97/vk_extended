//
//  TopicPageCollectionViewCell.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 04.12.2020.
//

import UIKit

protocol TopicSelectorDelegate: class {
    func selectTopic(for cell: TopicPageCollectionViewCell)
}

class TopicPageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var topicNameLabel: UILabel!
    
    weak var delegate: TopicSelectorDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        view.backgroundColor = .getThemeableColor(fromNormalColor: .white)
        view.drawBorder(8, width: 0.4, color: .getThemeableColor(fromNormalColor: .darkGray))
        
        topicNameLabel.textColor = .getThemeableColor(fromNormalColor: .darkGray)
        topicNameLabel.font = GoogleSansFont.semibold(with: 15)
        
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapTopic)))
    }

    func setSelected() {
        view.backgroundColor = UIColor.extendedBlue.withAlphaComponent(0.2)
        view.drawBorder(8, width: 0.4, color: UIColor.extendedBlue.withAlphaComponent(0.2))
        
        topicNameLabel.textColor = .extendedBlue
    }
    
    func setUnselected() {
        view.backgroundColor = .getThemeableColor(fromNormalColor: .white)
        view.drawBorder(8, width: 0.4, color: .getThemeableColor(fromNormalColor: .darkGray))
        
        topicNameLabel.textColor = .getThemeableColor(fromNormalColor: .darkGray)
    }
    
    @objc func onTapTopic(gestureRecognizer: UITapGestureRecognizer) {
        delegate?.selectTopic(for: self)
    }
}
