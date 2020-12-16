//
//  ProfileSectionController.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 25.11.2020.
//

import Foundation
import IGListKit
import SwiftMessages

class ProfileSectionController: ListBindingSectionController<ProfileViewModel.Cell>, ListBindingSectionControllerDataSource {
    var results = [ListDiffable]()

    override init() {
        super.init()
        dataSource = self
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, viewModelsFor object: Any) -> [ListDiffable] {
        guard let object = object as? ProfileViewModel.Cell else { fatalError() }
        results.append(ProfileCommonInfoViewModel(id: object.id, imageStatusUrl: object.imageStatusUrl, friendActionType: object.friendActionType, type: object.type, status: object.status, name: object.getFullName(nameCase: .nom), lastSeen: object.lastSeen, onlinePlatform: object.onlinePlatform, isOnline: object.isOnline, isMobile: object.isMobile, photo100: object.photo100, photoMax: object.photoMaxOrig, counters: object.counters, deactivated: object.deactivated != nil))
        results.append(NewsfeedDividerViewModel())
        if let deactivated = object.deactivated {
            if deactivated == "banned" {
                results.append(BannedInfoViewModel(causeText: "Страница \(object.getFullName(nameCase: .gen, true)) заблокирована", banType: .banned))
            } else {
                results.append(BannedInfoViewModel(causeText: "Страница \(object.getFullName(nameCase: .gen, true)) удалена", banType: .deleted))
            }
        }
        if object.deactivated == nil && !object.canAccessClosed {
            results.append(CloseInfoViewModel(causeText: "Это закрытый профиль", causeRecomendationText: "Добавьте \(object.getFullName(nameCase: .acc, true)) в друзья, чтобы смотреть \(object.sex == 1 ? "её" : "его") записи, фотографии и другие материалы", banType: .closed))
        }
        return results
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, cellForViewModel viewModel: Any, at index: Int) -> UICollectionViewCell & ListBindable {
        let identifier: String
        switch viewModel {
        case is ProfileCommonInfoViewModel:
            identifier = "ProfileCommonInfoCollectionViewCell"
            let cell = collectionContext?.dequeueReusableCell(withNibName: identifier, bundle: nil, for: sectionController, at: index) as! ProfileCommonInfoCollectionViewCell
            cell.delegate = self
            return cell
        case is BannedInfoViewModel:
            identifier = "BannedCollectionViewCell"
            let cell = collectionContext?.dequeueReusableCell(withNibName: identifier, bundle: nil, for: sectionController, at: index) as! BannedCollectionViewCell
            return cell
        case is CloseInfoViewModel:
            identifier = "ClosedOrBannedCollectionViewCell"
            let cell = collectionContext?.dequeueReusableCell(withNibName: identifier, bundle: nil, for: sectionController, at: index) as! ClosedCollectionViewCell
            return cell
        case is NewsfeedDividerViewModel:
            identifier = "DividerCollectionViewCell"
            let cell = collectionContext?.dequeueReusableCell(withNibName: identifier, bundle: nil, for: sectionController, at: index) as! DividerCollectionViewCell
            return cell
        default:
            fatalError()
        }
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, sizeForViewModel viewModel: Any, at index: Int) -> CGSize {
        guard let width = collectionContext?.containerSize.width, let object = sectionController.object as? ProfileViewModel.Cell else { fatalError() }
        var height: CGFloat
        switch viewModel {
        case is ProfileCommonInfoViewModel:
            height = 180
            if object.deactivated != nil {
                height -= 52
            } else {
                height -= 0
            }
        case is BannedInfoViewModel:
            if let deactivated = object.deactivated {
                if deactivated == "banned" {
                    height = "Страница \(object.getFullName(nameCase: .gen, true)) заблокирована".height(with: width, font: GoogleSansFont.medium(with: 13)) + 32
                } else {
                    height = "Страница \(object.getFullName(nameCase: .gen, true)) удалена".height(with: width, font: GoogleSansFont.medium(with: 13)) + 32
                }
            } else {
                height = 0
            }
        case is CloseInfoViewModel:
            let attrText = NSAttributedString(string: "Это закрытый профиль", attributes: [.font: GoogleSansFont.bold(with: 16), .foregroundColor: UIColor.getThemeableColor(fromNormalColor: .black)]) + attributedNewLine + NSAttributedString(string: "Добавьте \(object.getFullName(nameCase: .acc, true)) в друзья, чтобы смотреть \(object.sex == 1 ? "её" : "его") записи, фотографии и другие материалы", attributes: [.font: GoogleSansFont.medium(with: 14), .foregroundColor: UIColor.getThemeableColor(fromNormalColor: .lightGray)])
            height = 51 + attrText.height(with: width)
        case is NewsfeedDividerViewModel:
            height = 0.4
        default:
            height = 0
        }
        return .custom(width, height)
    }
}
extension ProfileSectionController: FriendActionDelegate {
    func openImagePopup(for cell: UICollectionViewCell & ListBindable, with userId: Int) {
        let status2 = MessageView.viewFromNib(layout: .popupView)
        status2.backgroundView.backgroundColor = .getThemeableColor(fromNormalColor: .white)
        
        status2.titleLabel?.textColor = .getThemeableColor(fromNormalColor: .black)
        status2.titleLabel?.font = GoogleSansFont.bold(with: 20)

        status2.bodyLabel?.textColor = .getThemeableColor(fromNormalColor: .darkGray)
        status2.bodyLabel?.font = GoogleSansFont.regular(with: 15)

        var status2Config = SwiftMessages.defaultConfig
        status2Config.duration = .forever
        status2Config.dimMode = .gray(interactive: true)
        status2Config.presentationStyle = .bottom
        status2Config.presentationContext = .window(windowLevel: .alert)
        status2Config.preferredStatusBarStyle = .default
        
        HapticFeedback.selection.generateFeedback()
        SwiftMessages.show(config: status2Config, view: status2)

        try! Api.Status.getImagePopup(userId: userId).done { imagePopup in
            status2.button?.backgroundColor = .getAccentColor(fromType: .button)
            status2.button?.setTitleColor(.getThemeableColor(fromNormalColor: .white), for: .normal)
            status2.button?.titleLabel?.font = GoogleSansFont.semibold(with: 17)

            status2.configurePopup(title: imagePopup.popup.title, body: imagePopup.popup.text, backgoroundImageUrl: imagePopup.popup.background.light.images.to(index: 1)?.url, imageUrl: imagePopup.popup.photo.images.to(index: 1)?.url, buttonTitle: "Закрыть") { (button) in
                SwiftMessages.hide()
            }
        }.catch { error in
            SwiftMessages.hide()
        }
    }
    
    func action(for cell: UICollectionViewCell & ListBindable, with action: FriendAction) {
        guard let profileViewController = viewController as? ProfileViewController else { return }
        if action != .notFriend && action != .notFriendWithNoRequest {
            profileViewController.initialActionSheet(title: nil, message: nil, actions: profileViewController.getFriendActions(with: action))
        }
    }
}
