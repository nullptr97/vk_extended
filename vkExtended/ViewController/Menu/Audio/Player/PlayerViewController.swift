//
//  PlayerViewController.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 18.11.2020.
//

import UIKit
import MaterialComponents
import Material
import Kingfisher

class PlayerViewController: UIViewController {
    
    @IBOutlet weak var blurredArtworkImageView: UIImageView!
    @IBOutlet weak var artworkImageView: UIImageView! {
        didSet {
            artworkImageView.backgroundColor = .adaptableDivider
        }
    }
    @IBOutlet weak var sliderView: UIView!
    @IBOutlet weak var progressSlider: BufferSlider! {
        didSet {
            progressSlider.bufferColor = UIColor.systemBlue.withAlphaComponent(0.25)
            progressSlider.setThumbImage(UIImage(named: "Hide Outgoing Unread Badge")?.crop(toWidth: 10, toHeight: 10)?.withRenderingMode(.alwaysTemplate).tint(with: .systemBlue), for: .normal)
            progressSlider.minimumTrackTintColor = .systemBlue
            progressSlider.maximumTrackTintColor = .systemBlue
            progressSlider.progressColor = .systemBlue
            progressSlider.baseColor = .systemBlue
            progressSlider.roundedSlider = true
            progressSlider.maximumValue = 1
        }
    }
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = GoogleSansFont.semibold(with: 24)
            titleLabel.textColor = .getThemeableColor(from: .black)
        }
    }
    @IBOutlet weak var artistLabel: UILabel! {
        didSet {
            artistLabel.font = GoogleSansFont.medium(with: 16)
            artistLabel.textColor = .systemBlue
        }
    }
    
    @IBOutlet weak var sliderTopPaddingConstraint: NSLayoutConstraint! {
        didSet {
            sliderTopPaddingConstraint.constant = screenWidth - (AudioService.instance.player.state == .playing ? 32 : 96)
        }
    }
    @IBOutlet weak var albumArtworkHeight: NSLayoutConstraint! {
        didSet {
            albumArtworkHeight.constant = screenWidth - (AudioService.instance.player.state == .playing ? 64 : 128)
        }
    }
    @IBOutlet weak var albumArtworkWidth: NSLayoutConstraint! {
        didSet {
            albumArtworkWidth.constant = screenWidth - (AudioService.instance.player.state == .playing ? 64 : 128)
        }
    }
    @IBOutlet weak var saveButton: UIButton! {
        didSet {
            saveButton.setImage(UIImage(named: "shuffle_24")?.withRenderingMode(.alwaysTemplate).tint(with: .getThemeableColor(from: .black)), for: .normal)
        }
    }
    @IBOutlet weak var prevButton: UIButton! {
        didSet {
            prevButton.setImage(UIImage(named: "skip_previous_48")?.withRenderingMode(.alwaysTemplate).tint(with: .getThemeableColor(from: .black)), for: .normal)
        }
    }
    @IBOutlet weak var playingButton: UIButton! {
        didSet {
            playingButton.setImage(UIImage(named: AudioService.instance.player.state == .playing ? "pause_48" : "play_48")?.withRenderingMode(.alwaysTemplate).tint(with: .getThemeableColor(from: .black)), for: .normal)
        }
    }
    @IBOutlet weak var nextButton: UIButton! {
        didSet {
            nextButton.setImage(UIImage(named: "skip_next_48")?.withRenderingMode(.alwaysTemplate).tint(with: .getThemeableColor(from: .black)), for: .normal)
        }
    }
    @IBOutlet weak var moreButton: UIButton! {
        didSet {
            moreButton.setImage(UIImage(named: "more_horizontal_28")?.withRenderingMode(.alwaysTemplate).tint(with: .getThemeableColor(from: .black)), for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        view.backgroundColor = .getThemeableColor(from: .white)

        sliderView.addSubview(progressSlider)
        progressSlider.autoPinEdgesToSuperviewEdges()
        progressSlider.addTarget(self, action: #selector(onSeek(sender:)), for: .valueChanged)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        progressSlider.minimumTrackTintColor = .adaptableGrayVK
        progressSlider.maximumTrackTintColor = .adaptableGrayVK
        saveButton.setImage(UIImage(named: "shuffle_24")?.withRenderingMode(.alwaysTemplate).tint(with: .getThemeableColor(from: .black)), for: .normal)
        prevButton.setImage(UIImage(named: "skip_previous_48")?.withRenderingMode(.alwaysTemplate).tint(with: .getThemeableColor(from: .black)), for: .normal)
        playingButton.setImage(UIImage(named: AudioService.instance.player.state == .playing ? "pause_48" : "play_48")?.withRenderingMode(.alwaysTemplate).tint(with: .getThemeableColor(from: .black)), for: .normal)
        nextButton.setImage(UIImage(named: "skip_next_48")?.withRenderingMode(.alwaysTemplate).tint(with: .getThemeableColor(from: .black)), for: .normal)
        moreButton.setImage(UIImage(named: "more_horizontal_28")?.withRenderingMode(.alwaysTemplate).tint(with: .getThemeableColor(from: .black)), for: .normal)
    }
    
    @objc func onSeek(sender: BufferSlider) {
        sender.newValue = sender.value
        sender.setNeedsDisplay()
        guard let duration = AudioService.instance.player.currentItem?.model.duration.cgFloat else { return }
        AudioService.instance.player.seek(to: (duration * sender.value.cgFloat).double)
    }
    
    @IBAction func onPlaying(_ sender: UIButton) {
        if AudioService.instance.player.state == .playing {
            pauseTrack()
        } else {
            resumeTrack()
        }
        playingButton.setImage(UIImage(named: AudioService.instance.player.state == .playing ? "pause_48" : "play_48")?.withRenderingMode(.alwaysTemplate).tint(with: .getThemeableColor(from: .black)), for: .normal)
    }
    
    @IBAction func onNextTrack(_ sender: UIButton) {
        nextTrack()
    }
    
    @IBAction func onPrevTrack(_ sender: UIButton) {
        prevTrack()
    }
}
extension PlayerViewController {
    func pauseTrack() {
        AudioService.instance.player.pause()
        albumArtworkWidth.constant = screenWidth - 128
        albumArtworkHeight.constant = screenWidth - 128
        
        UIView.animate(.promise, duration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func resumeTrack() {
        AudioService.instance.player.resume()
        albumArtworkWidth.constant = screenWidth - 64
        albumArtworkHeight.constant = screenWidth - 64
        
        UIView.animate(.promise, duration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func nextTrack() {
        AudioService.instance.player.next()
    }
    
    func prevTrack() {
        AudioService.instance.player.previous()
    }
}
