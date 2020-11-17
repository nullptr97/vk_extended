//
//  PhotoCollectionViewCell.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 28.10.2020.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var photoImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        photoImageView.backgroundColor = .adaptablePostColor
        photoImageView.setCorners(radius: 6)
    }
}
