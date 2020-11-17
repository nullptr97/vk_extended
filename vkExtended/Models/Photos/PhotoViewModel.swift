//
//  PhotoViewModel.swift
//  VKExt
//
//  Created by programmist_NA on 17.07.2020.
//

import Foundation

struct PhotoViewModel {
    struct Cell: PhotoCellViewModel {
        var photos: [ProfilePhotosViewModel]?
    }
    
    struct ProfilePhotosCellViewModel: ProfilePhotosViewModel {
        var photoMaxUrl: String?
        var photoUrlString: String?
        var width: Int
        var height: Int
    }

    var cell: [Cell]
    let footerTitle: String?
}

struct PhotosViewModel {
    struct Cell: PhotosCellViewModel {
        var photoMaxUrl: String?
        var photoUrlString: String?
        var width: Int
        var height: Int
    }

    var cells: [Cell]
    let footerTitle: String?
}

protocol PhotosCellViewModel {
    var photoMaxUrl: String? { get }
    var photoUrlString: String? { get }
    var width: Int { get }
    var height: Int { get }
}

protocol PhotoCellViewModel {
    var photos: [ProfilePhotosViewModel]? { get }
}

protocol ProfilePhotosViewModel {
    var photoMaxUrl: String? { get }
    var photoUrlString: String? { get }
    var width: Int { get }
    var height: Int { get }
}
