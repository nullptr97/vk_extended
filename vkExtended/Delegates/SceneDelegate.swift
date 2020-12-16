//
//  SceneDelegate.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 19.10.2020.
//

import UIKit
import MaterialComponents
import RealmSwift
import Lottie
import Alamofire
import SwiftyJSON

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var vkDelegate: ExtendedVKDelegate?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        vkDelegate = VKGeneralDelegate()

        let rootViewController = FullScreenNavigationController(rootViewController: BottomNavigationViewController())
        rootViewController.motionNavigationTransitionType = .zoom
        rootViewController.setNavigationBarHidden(true, animated: false)
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.windowScene = windowScene
        self.window?.rootViewController = rootViewController
        self.window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    func checkMember(completion: @escaping(Bool) -> Void) {
        let parameters: Alamofire.Parameters = [
            Parameter.groupId.rawValue: "extended_team",
            Parameter.extended.rawValue: 1,
            Parameter.userId.rawValue: currentUserId
        ]

        Request.dataRequest(method: ApiMethod.method(from: .groups, with: ApiMethod.Groups.isMember), parameters: parameters).done { response in
            switch response {
            case .success(let data):
                let responseJson = JSON(data)
                completion(responseJson["member"].intValue.boolValue)
                UserDefaults.standard.set(responseJson["member"].intValue.boolValue, forKey: "blockStatus")
            case .error(let error):
                print(error.toVK())
                completion(true)
            }
        }.catch { error in
            print(error.localizedDescription)
            completion(true)
        }
    }

    func setupOverlay() {
        let overlayView = UIView()
        overlayView.setBlurBackground(style: .regular)
        let overlayAnimationView = AnimationView()
        overlayAnimationView.animation = Animation.named("access_denied")
        guard let windowView = window?.rootViewController?.view else { return }
        if let window = self.window as? MDCOverlayWindow {
            window.activateOverlay(overlayView, withLevel: .alert)
        }
        UIView.transition(with: windowView, duration: 0.2, options: [.transitionCrossDissolve, .curveEaseIn], animations: {
            overlayView.addSubview(overlayAnimationView)
            overlayView.bringSubviewToFront(overlayAnimationView)
            overlayAnimationView.frame = overlayView.bounds
        }, completion: { _ in
            overlayAnimationView.play()
        })
    }
}

