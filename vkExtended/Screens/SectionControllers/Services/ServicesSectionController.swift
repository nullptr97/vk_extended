//
//  ServicesSectionController.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 13.12.2020.
//

import Foundation
import IGListKit
import ViewAnimator

class ServicesSectionController: ListBindingSectionController<SuperAppServices>, ListBindingSectionControllerDataSource {
    var results = [ListDiffable]()
    var items: [(String, String, UIColor)] = [("music_outline_28", "Музыка", UIColor.Themeable.dynamicBlue), ("users_3_outline_28", "Сообщества", UIColor.Themeable.dynamicOrange), ("video_outline_28", "Видео", UIColor.Themeable.dynamicViolet), ("document_outline_28", "Файлы", UIColor.Themeable.dynamicOrange), ("settings_outline_28", "Настройки", UIColor.Themeable.dynamicRed), ("bug_outline_28", "Debug", UIColor.Themeable.dynamicGreen)]

    override init() {
        super.init()
        dataSource = self
    }

    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, viewModelsFor object: Any) -> [ListDiffable] {
        guard let object = object as? SuperAppServices else { fatalError() }

        results.append(NewsfeedDividerViewModel())

        results.append(contentsOf: items.map { ServiceItemViewModel(image: $0.0, name: $0.1, color: $0.2) })
        
        results.append(NewsfeedDividerViewModel())

        let objects = object.items.map { objectItem in
            SuperAppItemViewModel(size: objectItem.size, object: SuperAppObjectViewModel(miniApp: object.miniApps.filter { objectItem.object.appID == $0.id }.first, count: objectItem.object.count, items: objectItem.object.items, button: objectItem.object.button, webviewURL: objectItem.object.webviewURL, title: objectItem.object.title, localIncreaseLabel: objectItem.object.localIncreaseLabel, appID: objectItem.object.appID, totalIncrease: objectItem.object.totalIncrease, timelineDynamic: objectItem.object.timelineDynamic, totalIncreaseLabel: objectItem.object.totalIncreaseLabel, localIncrease: objectItem.object.localIncrease, images: objectItem.object.images, temperature: objectItem.object.temperature, shortDescriptionAdditionalValue: objectItem.object.shortDescriptionAdditionalValue, shortDescription: objectItem.object.shortDescription, mainDescription: objectItem.object.mainDescription, trackCode: objectItem.object.trackCode, additionalText: objectItem.object.additionalText, mainText: objectItem.object.mainText, link: objectItem.object.link, coverPhotosURL: objectItem.object.coverPhotosURL, headerIcon: objectItem.object.headerIcon, payload: objectItem.object.payload, state: objectItem.object.state, footerText: objectItem.object.footerText, buttonExtra: objectItem.object.buttonExtra, matches: objectItem.object.matches, isLocal: objectItem.object.isLocal), type: objectItem.type)
        }
        
        let s = objects.filter { $0.type == "greeting" }.first?.object.items?.filter { $0.type == "primary" }
        results.append(ServiceDateViewModel(title: "Сегодня", text: todayDate, welcomeText: s?.compactMap { $0.text }, to: s?.compactMap { $0.to }, from: s?.compactMap { $0.from }))
        
        let pizdecFilteredObjects = objects.filter { filteredObject in
            filteredObject.object.miniApp != nil || !filteredObject.object.headerIcon.isNilOrEmpty || !filteredObject.object.images.isNilOrEmpty || !filteredObject.object.coverPhotosURL.isNilOrEmpty
        }.map { $0.object }
        results.append(contentsOf: pizdecFilteredObjects
                        .filter { !($0.title ?? "").contains("Спорт", caseSensitive: false) }
                        .filter { !($0.title ?? "").contains("Такси Вконтакте", caseSensitive: false) })
        return results
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, cellForViewModel viewModel: Any, at index: Int) -> UICollectionViewCell & ListBindable {
        let identifier: String
        switch viewModel {
        case is ServiceItemViewModel:
            identifier = "ServiceItemCollectionViewCell"
            let cell = collectionContext?.dequeueReusableCell(withNibName: identifier, bundle: nil, for: sectionController, at: index) as! ServiceItemCollectionViewCell
            cell.delegate = self
            if !cell.isAnimated { UIView.animate(views: [cell], animations: [AnimationType.zoom(scale: 0.35)], duration: 0.3) }
            cell.isAnimated = true
            return cell
        case is ServiceDateViewModel:
            identifier = "ServiceTimeCollectionViewCell"
            let cell = collectionContext?.dequeueReusableCell(withNibName: identifier, bundle: nil, for: sectionController, at: index) as! ServiceTimeCollectionViewCell
            if !cell.isAnimated { UIView.animate(views: [cell], animations: [AnimationType.vector(CGVector(dx: 0, dy: -50))], duration: 0.3) }
            cell.isAnimated = true
            return cell
        case is SuperAppObjectViewModel:
            identifier = "ServicesAppCollectionViewCell"
            let cell = collectionContext?.dequeueReusableCell(withNibName: identifier, bundle: nil, for: sectionController, at: index) as! ServicesAppCollectionViewCell
            if !cell.isAnimated { UIView.animate(views: [cell], animations: [AnimationType.vector(CGVector(dx: 0, dy: -50))], duration: 0.3) }
            cell.isAnimated = true
            cell.miniAppDelegate = self
            return cell
        case is NewsfeedDividerViewModel:
            identifier = "DividerCollectionViewCell"
            let cell = collectionContext?.dequeueReusableCell(withNibName: identifier, bundle: nil, for: sectionController, at: index) as! DividerCollectionViewCell
            cell.backgroundColor = .clear
            return cell
        default:
            fatalError()
        }
    }
    
    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, sizeForViewModel viewModel: Any, at index: Int) -> CGSize {
        guard let collectionContext = collectionContext else { fatalError() }
        var height: CGFloat
        var width: CGFloat
        switch viewModel {
        case is ServiceItemViewModel:
            height = 82
            width = collectionContext.containerSize.width / 3
        case is ServiceDateViewModel:
            height = 48
            width = collectionContext.containerSize.width
        case is SuperAppObjectViewModel:
            height = 52
            width = collectionContext.containerSize.width
            switch (viewModel as! SuperAppObjectViewModel).appID {
            case 7362610 where (viewModel as! SuperAppObjectViewModel).title == "Распространение COVID‑19":
                height += 48
            case 7362610 where (viewModel as! SuperAppObjectViewModel).title == nil:
                height += ((viewModel as! SuperAppObjectViewModel).additionalText?.height(with: width - 52, font: GoogleSansFont.regular(with: 14)) ?? 0)
            case 7368392:
                height -= 52
            case 7293255:
                height += 52
            default:
                height += 48
            }
        case is NewsfeedDividerViewModel:
            width = collectionContext.containerSize.width
            height = 16
        default:
            width = 0
            height = 0
        }
        return .custom(width, height)
    }
    
    var todayDate: String {
        let dt = DateFormatter()
        dt.locale = Locale(identifier: "ru_RU")
        dt.dateFormat = "d MMMM"
        return dt.string(from: Date())
    }
}
extension ServicesSectionController: ServiceItemTapHandler {
    func onTapMusic(for cell: UICollectionViewCell & ListBindable) {
        viewController?.navigationController?.pushViewController(AudioViewController(), animated: true)
    }
    
    func onTapGroups(for cell: UICollectionViewCell & ListBindable) {
        viewController?.navigationController?.pushViewController(GroupsViewController(), animated: true)
    }
    
    func onTapSettings(for cell: UICollectionViewCell & ListBindable) {
        viewController?.navigationController?.pushViewController(UISettingsViewController(), animated: true)
    }
    
    func onTapDebug(for cell: UICollectionViewCell & ListBindable) {
        viewController?.navigationController?.pushViewController(TestingViewController(), animated: true)
    }
}
extension ServicesSectionController: ServicesAppHandler {
    func openMiniApp(from url: String) {
        guard let url = URL(string: url) else { return }
        let miniAppViewController = MiniAppViewController(url: url)
        viewController?.present(miniAppViewController, animated: true)
    }
}
