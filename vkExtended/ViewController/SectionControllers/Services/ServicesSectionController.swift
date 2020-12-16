//
//  ServicesSectionController.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 13.12.2020.
//

import Foundation
import IGListKit

class ServicesSectionController: ListBindingSectionController<SuperAppServices>, ListBindingSectionControllerDataSource {
    var results = [ListDiffable]()
    var items: [(String, String, UIColor)] = [("music_outline_28", "Музыка", .getAccentColor(fromType: .common)), ("users_3_outline_28", "Сообщества", .adaptableOrange), ("video_outline_28", "Видео", .adaptableViolet), ("document_outline_28", "Файлы", ExtendedColors.secondary), ("settings_outline_28", "Настройки", .extendedBackgroundRed), ("bug_outline_28", "Debug", .extendedGreen)]

    override init() {
        super.init()
        dataSource = self
    }

    func sectionController(_ sectionController: ListBindingSectionController<ListDiffable>, viewModelsFor object: Any) -> [ListDiffable] {
        guard let object = object as? SuperAppServices else { fatalError() }

        results.append(NewsfeedDividerViewModel())
        results.append(contentsOf: items.map { ServiceItemViewModel(image: $0.0, name: $0.1, color: $0.2) })
        results.append(NewsfeedDividerViewModel())
        
        let objects = object.items.compactMap { item in
            return SuperAppObjectViewModel(miniApp: object.miniApps.filter { item.object.appID == $0.id }.first, count: item.object.count, items: item.object.items, button: item.object.button, webviewURL: item.object.webviewURL, title: item.object.title, localIncreaseLabel: item.object.localIncreaseLabel, appID: item.object.appID, totalIncrease: item.object.totalIncrease, timelineDynamic: item.object.timelineDynamic, totalIncreaseLabel: item.object.totalIncreaseLabel, localIncrease: item.object.localIncrease, images: item.object.images, temperature: item.object.temperature, shortDescriptionAdditionalValue: item.object.shortDescriptionAdditionalValue, shortDescription: item.object.shortDescription, mainDescription: item.object.mainDescription, trackCode: item.object.trackCode, additionalText: item.object.additionalText, mainText: item.object.mainText, link: item.object.link, coverPhotosURL: item.object.coverPhotosURL, headerIcon: item.object.headerIcon, payload: item.object.payload, state: item.object.state, footerText: item.object.footerText, buttonExtra: item.object.buttonExtra, matches: item.object.matches, isLocal: item.object.isLocal)
        }
        let pizdecFilteredObjects = objects.filter { filteredObject in
            filteredObject.miniApp != nil || !filteredObject.headerIcon.isNilOrEmpty || !filteredObject.images.isNilOrEmpty || !filteredObject.coverPhotosURL.isNilOrEmpty
        }
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
            return cell
        case is SuperAppObjectViewModel:
            identifier = "ServicesAppCollectionViewCell"
            let cell = collectionContext?.dequeueReusableCell(withNibName: identifier, bundle: nil, for: sectionController, at: index) as! ServicesAppCollectionViewCell
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
        case is SuperAppObjectViewModel:
            height = 52
            width = collectionContext.containerSize.width
            switch (viewModel as! SuperAppObjectViewModel).appID {
            case 7362610 where (viewModel as! SuperAppObjectViewModel).title == "Распространение COVID‑19":
                height += 48
            case 7362610 where (viewModel as! SuperAppObjectViewModel).title == nil:
                height += ((viewModel as! SuperAppObjectViewModel).title?.height(with: width - 52, font: GoogleSansFont.regular(with: 14)) ?? 0) + 12 + 24
            case 7368392:
                height -= 52
            case 7293255:
                height += 48
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
}
extension ServicesSectionController: ServiceItemTapHandler {
    func onTapMusic(for cell: ServiceItemCollectionViewCell) {
        viewController?.navigationController?.pushViewController(AudioViewController(), animated: true)
    }
    
    func onTapSettings(for cell: ServiceItemCollectionViewCell) {
        viewController?.navigationController?.pushViewController(UISettingsViewController(), animated: true)
    }
    
    func onTapDebug(for cell: ServiceItemCollectionViewCell) {
        viewController?.navigationController?.pushViewController(TestingViewController(), animated: true)
    }
}
