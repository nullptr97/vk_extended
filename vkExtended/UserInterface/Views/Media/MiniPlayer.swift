//
//  MiniPlayer.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 18.11.2020.
//

import UIKit
import Material

class MiniPlayer: View {
    @IBOutlet var miniPlayer: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var playingButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        Bundle.main.loadNibNamed("MiniPlayer", owner: self, options: nil)
        addSubview(miniPlayer)
        miniPlayer.frame = bounds
        miniPlayer.backgroundColor = .getThemeableColor(from: .white)
        
        titleLabel.font = GoogleSansFont.medium(with: 15)
        titleLabel.textColor = .getThemeableColor(from: .black)
        
        artistLabel.font = GoogleSansFont.regular(with: 12)
        artistLabel.textColor = .adaptableDarkGrayVK
        
        playingButton.contentMode = .center
        closeButton.contentMode = .center
        
        dividerAlignment = .bottom
        dividerThickness = 0.4
        dividerColor = .adaptableDivider
    }
    
    func setupPlayer(from state: AudioPlayerState) {
        switch state {
        case .buffering:
            isHidden = false
            isUserInteractionEnabled = true
            playingButton.setImage(UIImage(named: "play_48")?.withRenderingMode(.alwaysTemplate).tint(with: .systemBlue), for: .normal)
            closeButton.setImage(UIImage(named: "cancel_outline_36")?.withRenderingMode(.alwaysTemplate).tint(with: .adaptableDarkGrayVK), for: .normal)
        case .playing:
            isHidden = false
            isUserInteractionEnabled = true
            playingButton.setImage(UIImage(named: "pause_48")?.withRenderingMode(.alwaysTemplate).tint(with: .systemBlue), for: .normal)
            closeButton.setImage(UIImage(named: "skip_next_48")?.withRenderingMode(.alwaysTemplate).tint(with: .adaptableDarkGrayVK), for: .normal)
        case .paused:
            isHidden = false
            isUserInteractionEnabled = true
            playingButton.setImage(UIImage(named: "play_48")?.withRenderingMode(.alwaysTemplate).tint(with: .systemBlue), for: .normal)
            closeButton.setImage(UIImage(named: "cancel_outline_36")?.withRenderingMode(.alwaysTemplate).tint(with: .adaptableDarkGrayVK), for: .normal)
        case .stopped:
            isHidden = true
            isUserInteractionEnabled = false
            playingButton.setImage(UIImage(named: "play_48")?.withRenderingMode(.alwaysTemplate).tint(with: .systemBlue), for: .normal)
            closeButton.setImage(UIImage(named: "cancel_outline_36")?.withRenderingMode(.alwaysTemplate).tint(with: .adaptableDarkGrayVK), for: .normal)
        case .waitingForConnection:
            isUserInteractionEnabled = true
            playingButton.setImage(UIImage(named: "play_48")?.withRenderingMode(.alwaysTemplate).tint(with: .systemBlue), for: .normal)
            closeButton.setImage(UIImage(named: "cancel_outline_36")?.withRenderingMode(.alwaysTemplate).tint(with: .adaptableDarkGrayVK), for: .normal)
        case .failed(_):
            isHidden = true
            isUserInteractionEnabled = false
            playingButton.setImage(UIImage(named: "play_48")?.withRenderingMode(.alwaysTemplate).tint(with: .systemBlue), for: .normal)
            closeButton.setImage(UIImage(named: "cancel_outline_36")?.withRenderingMode(.alwaysTemplate).tint(with: .adaptableDarkGrayVK), for: .normal)
        }
    }

    open var artistTitle: String? {
        get { return artistLabel.text }
        set { artistLabel.text = newValue }
    }
    
    open var nameTitle: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
}
