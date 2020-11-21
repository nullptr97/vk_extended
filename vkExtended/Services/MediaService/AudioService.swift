//
//  AudioService.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 18.11.2020.
//

import Foundation
import AVFoundation

enum AudioAction {
    case pause
    case play
    case resume
    case stop
    case next
    case prev
}

class AudioService {
    let player = AudioPlayer()
    static let instance = AudioService()
    var items = [AudioItem]()
    
    deinit {
        print("\(String(describing: Self.self)) deinited")
    }
    
    convenience init(items: [AudioItem]) {
        self.init()
        self.items = items
    }
    
    func appendItems(items: [AudioItem]) {
        self.items.append(contentsOf: items)
        player.add(items: items)
    }
    
    func action(_ action: AudioAction, index: Int = 0) {
        switch action {
        case .pause:
            player.pause()
            postNotification(name: .onPlayerPause)
        case .play:
            player.play(items: items, startAtIndex: index)
            postNotification(name: .onPlayerStart)
        case .resume:
            player.resume()
            postNotification(name: .onPlayerResume)
        case .stop:
            player.stop()
            postNotification(name: .onPlayerStop)
        case .next:
            player.next()
            postNotification(name: .onPlayerNext)
        case .prev:
            player.previous()
            postNotification(name: .onPlayerPrev)
        }
    }
}
