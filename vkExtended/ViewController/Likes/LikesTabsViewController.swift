//
//  LikesTabsViewController.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 03.12.2020.
//

import UIKit
import Material

class LikesTabsViewController: BaseTabsViewController, LikesTabsViewProtocol {
    var presenter: LikesTabsPresenterProtocol?
    
    override init(viewControllers: [UIViewController], selectedIndex: Int = 0) {
        super.init(viewControllers: viewControllers, selectedIndex: selectedIndex)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        LikesTabsRouter.initModule(self)
        title = "Оценили"
        
        delegate = self
//        (navigationController as? FullScreenNavigationController)?.fullScreenPanGestureRecognizer.delegate = self
    }
    
    func makeRequest(isFriends: Bool = false) {
        guard let firstViewController = viewControllers.first as? LikesViewController else { return }
        if isFriends {
            presenter?.start(request: .getFriendsLikes(postId: firstViewController.postId, sourceId: firstViewController.sourceId, type: firstViewController.type, friendsOnly: true))
        } else {
            presenter?.start(request: .getLikes(postId: firstViewController.postId, sourceId: firstViewController.sourceId, type: firstViewController.type))
        }
    }
    
    func displayData(viewModel: LikesModel.ViewModel.ViewModelData) {
        switch viewModel {
        case .displayLikes(profileViewModel: let profileViewModel):
            guard let firstViewController = viewControllers.first as? LikesViewController else { return }
            firstViewController.displayData(viewModel: profileViewModel)
        case .displayFriendsLikes(profileViewModel: let profileViewModel):
            guard let lastViewController = viewControllers.last as? FriendsLikesViewController else { return }
            lastViewController.displayData(viewModel: profileViewModel)
        }
    }
}
extension LikesTabsViewController: TabsControllerDelegate {
    func tabsController(tabsController: TabsController, didSelect viewController: UIViewController) {
//        switch tabsController.selectedIndex {
//        case 0:
////            (navigationController as? FullScreenNavigationController)?.fullScreenPanGestureRecognizer.isEnabled = true
//        case 1:
////            (navigationController as? FullScreenNavigationController)?.fullScreenPanGestureRecognizer.isEnabled = false
//        default:
////            (navigationController as? FullScreenNavigationController)?.fullScreenPanGestureRecognizer.isEnabled = false
//        }
    }
}
extension LikesTabsViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
