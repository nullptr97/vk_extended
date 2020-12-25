//
//  AudioInteractor.swift
//  vkExtended
//
//  Created Ярослав Стрельников on 15.11.2020.
//  Copyright © 2020 ExtendedTeam. All rights reserved.
//
import UIKit
import PromiseKit
import Alamofire
import SwiftyJSON
import AwesomeCache

class AudioInteractor: AudioInteractorProtocol {

    weak var presenter: AudioPresenterProtocol?
    let cache = try! Cache<NSData>(name: "audioCache")

    func getAudio(ownerId: Int) {
        presenter?.onPresentLoader(with: "")
        
        if let audioCache = cache["audio_from_id\(ownerId)"] as Data? {
            let response = audioCache.json()["items"].arrayValue.compactMap { AudioViewModel(audio: $0) }
            presenter?.onPresentAudio(audioViewModels: response)
        } else {
            presenter?.onPresentLoader(with: "")
        }
        
        do {
            try Api.Audio.get(ownerId: ownerId).done { [weak self] audios in
                guard let self = self else { return }
                self.presenter?.onPresentAudio(audioViewModels: audios)
            }.catch { [weak self] error in
                guard let self = self else { return }
                self.presenter?.onEvent(message: error.toVK().toApi()?.message ?? error.localizedDescription, isError: true)
                self.presenter?.onPresentLoader(with: error.toVK().toApi()?.message ?? "")
            }
        } catch {
            self.presenter?.onEvent(message: error.localizedDescription, isError: true)
        }
        
    }
}
