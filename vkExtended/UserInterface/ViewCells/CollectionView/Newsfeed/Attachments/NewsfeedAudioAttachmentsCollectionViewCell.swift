//
//  NewsfeedAudioAttachmentsCollectionViewCell.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 23.11.2020.
//

import UIKit
import IGListKit

class NewsfeedAudioAttachmentsCollectionViewCell: UICollectionViewCell, ListBindable {

    var audioAttachmentsCollectionView = AudioCollectionView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addSubview(audioAttachmentsCollectionView)
        audioAttachmentsCollectionView.autoPinEdgesToSuperviewEdges(with: .top(4))
    }

    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? NewsfeedAudioAttachmentsViewModel else { return }
        audioAttachmentsCollectionView.set(audios: viewModel.audioAttachements)
    }
}
