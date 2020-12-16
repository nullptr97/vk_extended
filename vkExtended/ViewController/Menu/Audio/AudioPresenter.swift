//
//  AudioPresenter.swift
//  vkExtended
//
//  Created Ярослав Стрельников on 15.11.2020.
//  Copyright © 2020 ExtendedTeam. All rights reserved.
//
import UIKit

class AudioPresenter: AudioPresenterProtocol {

    weak private var view: AudioViewProtocol?
    var interactor: AudioInteractorProtocol?
    private let router: AudioWireframeProtocol

    init(interface: AudioViewProtocol, interactor: AudioInteractorProtocol?, router: AudioWireframeProtocol) {
        self.view = interface
        self.interactor = interactor
        self.router = router
    }

    func onStart() {
        guard let interactor = interactor else { return }
        interactor.getAudio()
    }
    
    // Действие при событии
    func onEvent(message: String, isError: Bool = false) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.view?.event(message: message, isError: isError)
        })
    }
    
    // Показать загрузку
    func onPresentLoader(with error: String = "") {
        DispatchQueue.main.async {
            self.view?.presentLoader(with: error)
        }
    }
    
    // Показать музыку
    func onPresentAudio(audioViewModels: [AudioViewModel]) {
        DispatchQueue.main.async {
            self.view?.presentAudio(audioViewModels: audioViewModels)
        }
    }
}
