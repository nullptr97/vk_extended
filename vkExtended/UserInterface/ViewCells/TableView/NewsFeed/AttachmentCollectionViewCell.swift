//
//  AttachmentCollectionViewCell.swift
//  VKExt
//
//  Created by programmist_NA on 11.07.2020.
//

import Foundation
import UIKit
import Kingfisher

class GalleryCollectionViewCell: UICollectionViewCell {
    
    static let reuseId = "GalleryCollectionViewCell"
    
    let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    let blurImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(blurImageView)
        blurImageView.autoPinEdgesToSuperviewEdges()
        blurImageView.blur(withStyle: .regular)
        
        addSubview(photoImageView)
        photoImageView.autoPinEdgesToSuperviewEdges()
    }
    
    override func prepareForReuse() {
        photoImageView.image = nil
        blurImageView.image = nil
    }
    
    func set(imageUrl: String?) {
        guard let url = URL(string: imageUrl) else { return }
        self.photoImageView.kf.setImage(with: url)
        self.blurImageView.kf.setImage(with: url)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
