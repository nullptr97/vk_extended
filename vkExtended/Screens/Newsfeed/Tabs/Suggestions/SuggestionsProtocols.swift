//
//  SuggestionsProtocols.swift
//  VKExt
//
//  Created programmist_NA on 12.07.2020.
//  Copyright © 2020 ExtendedTeam. All rights reserved.
//
import Foundation
import UIKit

//MARK: Wireframe -
protocol SuggestionsWireframeProtocol: class {
    
}
//MARK: Presenter -
protocol SuggestionsPresenterProtocol: class {
    func start(request: Newsfeed.Model.Request.RequestType)
    func presentData(response: Newsfeed.Model.Response.ResponseType)
}

//MARK: Interactor -
protocol SuggestionsInteractorProtocol: class {
    var presenter: SuggestionsPresenterProtocol?  { get set }
    func start(request: Newsfeed.Model.Request.RequestType)
    func makeRequest(request: Newsfeed.Model.Request.RequestType)
}

//MARK: View -
protocol SuggestionsViewProtocol: class {
    var presenter: SuggestionsPresenterProtocol?  { get set }
    func displayData(viewModel: Newsfeed.Model.ViewModel.ViewModelData)
}
