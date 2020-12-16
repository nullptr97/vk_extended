//
//  PhotoViewModel.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 28.10.2020.
//

import Foundation
import IGListKit

class PhotoViewModel: ListDiffable {
    private var identifier: String = UUID().uuidString

    struct Cell: PhotoCellViewModel {
        var photoMaxUrl: String?
        var photoUrlString: String?
        var width: Int
        var height: Int
    }

    var cell: [Cell]
    let footerTitle: String?
    var count: Int
    
    init(cell: [Cell], footerTitle: String?, count: Int) {
        self.cell = cell
        self.footerTitle = footerTitle
        self.count = count
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? PhotoViewModel else {
            return false
        }
        
        return self.identifier == object.identifier
    }
}

protocol PhotoCellViewModel {
    var photoMaxUrl: String? { get }
    var photoUrlString: String? { get }
    var width: Int { get }
    var height: Int { get }
}
