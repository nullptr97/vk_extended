//
//  PhotoViewModel.swift
//  vkExtended
//
//  Created by Ярослав Стрельников on 28.10.2020.
//

import Foundation

struct PhotoViewModel {
    struct Cell: PhotoCellViewModel {
        var photoMaxUrl: String?
        var photoUrlString: String?
        var width: Int
        var height: Int
    }

    var cell: [Cell]
    let footerTitle: String?
}

protocol PhotoCellViewModel {
    var photoMaxUrl: String? { get }
    var photoUrlString: String? { get }
    var width: Int { get }
    var height: Int { get }
}
