//
//  AudioProtocols.swift
//  vkExtended
//
//  Created Ярослав Стрельников on 15.11.2020.
//  Copyright © 2020 ExtendedTeam. All rights reserved.
//
import Foundation

//MARK: Wireframe -
protocol AudioWireframeProtocol: class {

}
//MARK: Presenter -
protocol AudioPresenterProtocol: class {
    func onStart()
    func onEvent(message: String, isError: Bool)
    func onPresentAudio(audioViewModels: [AudioViewModel])
    func onPresentLoader(with error: String)
}

//MARK: Interactor -
protocol AudioInteractorProtocol: class {
  var presenter: AudioPresenterProtocol?  { get set }
    func getAudio()
}

//MARK: View -
protocol AudioViewProtocol: class {
  var presenter: AudioPresenterProtocol?  { get set }
    func event(message: String, isError: Bool)
    func presentAudio(audioViewModels: [AudioViewModel])
    func presentLoader(with error: String)
}
