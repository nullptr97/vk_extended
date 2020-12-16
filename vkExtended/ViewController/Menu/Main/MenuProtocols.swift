//
//  MenuProtocols.swift
//  vkExtended
//
//  Created Ярослав Стрельников on 15.11.2020.
//  Copyright © 2020 ExtendedTeam. All rights reserved.
//
import Foundation

//MARK: Wireframe -
protocol MenuWireframeProtocol: class {

}
//MARK: Presenter -
protocol MenuPresenterProtocol: class {

}

//MARK: Interactor -
protocol MenuInteractorProtocol: class {

  var presenter: MenuPresenterProtocol?  { get set }
}

//MARK: View -
protocol MenuViewProtocol: class {

  var presenter: MenuPresenterProtocol?  { get set }
}
