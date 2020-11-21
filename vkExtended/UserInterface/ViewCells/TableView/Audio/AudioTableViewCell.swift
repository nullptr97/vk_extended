//
//  AudioTableViewCell.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 17.11.2020.
//

import UIKit
import Material
import Lottie

enum AudioCellState {
    case playing
    case paused
    case notPlaying
}

class AudioTableViewCell: TableViewCell {
    @IBOutlet weak var audioImageView: UIImageView! {
        didSet {
            audioImageView.backgroundColor = .adaptableDivider
        }
    }
    @IBOutlet weak var audioTitleLabel: UILabel! {
        didSet {
            audioTitleLabel.font = GoogleSansFont.medium(with: 16)
            audioTitleLabel.textColor = .getThemeableColor(from: .black)
        }
    }
    @IBOutlet weak var audioArtistLabel: UILabel! {
        didSet {
            audioArtistLabel.font = GoogleSansFont.regular(with: 13)
            audioArtistLabel.textColor = .adaptableDarkGrayVK
        }
    }
    @IBOutlet weak var audioDurationLabel: UILabel! {
        didSet {
            audioDurationLabel.font = GoogleSansFont.regular(with: 12)
            audioDurationLabel.textColor = .adaptableDarkGrayVK
        }
    }
    @IBOutlet weak var playingAnimationView: AnimationView!
    @IBOutlet weak var overlayAvatarView: UIView! {
        didSet {
            overlayAvatarView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .getThemeableColor(from: .white)
        contentView.backgroundColor = .getThemeableColor(from: .white)

        playingAnimationView.backgroundColor = .clear
        playingAnimationView.loopMode = .loop
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupCell(audioViewModel: AudioViewModel, state: AudioCellState) {
        if let url = URL(string: audioViewModel.album.imageUrl) {
            audioImageView.contentMode = .scaleAspectFit
            audioImageView.kf.setImage(with: url)
        } else {
            audioImageView.contentMode = .center
            audioImageView.image = UIImage(named: "music_outline_28")
        }
        switch state {
        case .playing:
            playingAnimationView.isHidden = false
            playingAnimationView.play()
            overlayAvatarView.isHidden = false
        case .paused:
            playingAnimationView.isHidden = false
            playingAnimationView.pause()
            overlayAvatarView.isHidden = false
        case .notPlaying:
            playingAnimationView.isHidden = true
            playingAnimationView.stop()
            overlayAvatarView.isHidden = true
        }
        audioTitleLabel.text = audioViewModel.title
        audioArtistLabel.text = audioViewModel.artist
        audioTitleLabel.sizeToFit()
        audioArtistLabel.sizeToFit()
        audioDurationLabel.text = TimeInterval(audioViewModel.duration).stringDuration
    }
}
