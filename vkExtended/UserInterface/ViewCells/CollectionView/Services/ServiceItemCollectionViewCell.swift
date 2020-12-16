//
//  ServiceItemCollectionViewCell.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 15.12.2020.
//

import UIKit
import IGListKit

protocol ServiceItemTapHandler: class {
    func onTapMusic(for cell: ServiceItemCollectionViewCell)
    func onTapSettings(for cell: ServiceItemCollectionViewCell)
    func onTapDebug(for cell: ServiceItemCollectionViewCell)
}

class ServiceItemCollectionViewCell: UICollectionViewCell, ListBindable {
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemLabel: UILabel!
    
    weak var delegate: ServiceItemTapHandler?
    var type: ServiceItemType?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        itemLabel.textColor = .getThemeableColor(fromNormalColor: .black)
        itemLabel.font = GoogleSansFont.medium(with: 14)
        
        isUserInteractionEnabled = true
    }
    
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? ServiceItemViewModel else { return }
        itemImageView.image = UIImage(named: viewModel.image)?.withRenderingMode(.alwaysTemplate).tint(with: viewModel.color)
        itemLabel.text = viewModel.name
        type = viewModel.type
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapFromSelf)))
    }
    
    @objc func onTapFromSelf() {
        guard let itemType = type else { return }
        switch itemType {
        case .music:
            delegate?.onTapMusic(for: self)
        case .settings:
            delegate?.onTapSettings(for: self)
        case .debug:
            delegate?.onTapDebug(for: self)
        default:
            break
        }
    }
}
