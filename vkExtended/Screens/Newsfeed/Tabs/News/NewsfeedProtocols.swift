//
//  NewsfeedProtocols.swift
//  vkExtended
//
//  Created Ярослав Стрельников on 26.10.2020.
//  Copyright © 2020 ExtendedTeam. All rights reserved.
//
import Foundation

//MARK: Wireframe -
protocol NewsfeedWireframeProtocol: class {

}
//MARK: Presenter -
protocol NewsfeedPresenterProtocol: class {
    func start(request: Newsfeed.Model.Request.RequestType)
    func presentData(response: Newsfeed.Model.Response.ResponseType)
}

//MARK: Interactor -
protocol NewsfeedInteractorProtocol: class {
    var presenter: NewsfeedPresenterProtocol?  { get set }
    func start(request: Newsfeed.Model.Request.RequestType)
    func makeRequest(request: Newsfeed.Model.Request.RequestType)
}

//MARK: View -
protocol NewsfeedViewProtocol: class {
    var presenter: NewsfeedPresenterProtocol?  { get set }
    func displayData(viewModel: Newsfeed.Model.ViewModel.ViewModelData)
}
