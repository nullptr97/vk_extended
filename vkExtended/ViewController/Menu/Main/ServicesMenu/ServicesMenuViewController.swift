//
//  ServicesMenuViewController.swift
//  vkExtended
//
//  Created Ярослав Стрельников on 15.11.2020.
//  Copyright © 2020 ExtendedTeam. All rights reserved.
//
import UIKit
import Material
import IGListKit
import DRPLoadingSpinner
import CoreLocation

class ServicesMenuViewController: BaseViewController, ServicesMenuViewProtocol {

	internal var presenter: ServicesMenuPresenterProtocol?

    let mainCollection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private lazy var adapter: ListAdapter = {
        let listAdapter = ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 1)
        listAdapter.collectionView = mainCollection
        listAdapter.dataSource = self
        return listAdapter
    }()
    var data = [ListDiffable]()
    private var locationManager: CLLocationManager?
    
    private var latitude: Double?
    private var longitude: Double?
    
	override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager?.requestWhenInUseAuthorization()
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
            latitude = locationManager?.location?.coordinate.latitude
            longitude = locationManager?.location?.coordinate.longitude
        }
        
        ServicesMenuRouter.initModule(self)
        
        prepareCollection()
        setupCollection()
        
        navigationTitle = "Сервисы"
        
        presenter?.onGetSuperApp(lat: latitude, lon: longitude)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
    }
    
    // Подготовка коллекции
    func prepareCollection() {
        view.addSubview(mainCollection)
        mainCollection.autoPinEdge(toSuperviewSafeArea: .top, withInset: 12)
        mainCollection.autoPinEdge(.bottom, to: .bottom, of: view)
        mainCollection.autoPinEdge(.trailing, to: .trailing, of: view)
        mainCollection.autoPinEdge(.leading, to: .leading, of: view)
        mainCollection.backgroundColor = .getThemeableColor(fromNormalColor: .white)
        mainCollection.contentInset.bottom = 52
    }
    
    // Настройка коллекции
    func setupCollection() {
        mainCollection.keyboardDismissMode = .onDrag
        mainCollection.allowsMultipleSelection = true
        refreshControl.loadingSpinner.colorSequence = [.getThemeableColor(fromNormalColor: .darkGray)]
        refreshControl.add(to: mainCollection) { [weak self] in
            guard let self = self else { return }
            self.presenter?.onGetSuperApp(lat: self.latitude, lon: self.longitude)
        }
    }
    
    func display(_ superApp: SuperAppServices) {
        self.data = [superApp]
        refreshControl.endRefreshing()
        adapter.reloadData { [weak self] (isSuccess) in
            guard isSuccess, let self = self else { return }
            self.mainCollection.reloadData()
        }
    }
}
extension ServicesMenuViewController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return data
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return ServicesSectionController()
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        mainCollection.setFooter()
        return mainCollection.backgroundView
    }
}
