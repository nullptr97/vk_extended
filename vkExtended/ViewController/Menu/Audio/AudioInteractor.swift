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

class AudioInteractor: AudioInteractorProtocol {

    weak var presenter: AudioPresenterProtocol?
    
    func getAudio() {
        presenter?.onPresentLoader(with: "")
        do {
            try Api.Audio.get().done { [weak self] audios in
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
