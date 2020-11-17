//
//  StoriesViewModel.swift
//  VKExt
//
//  Created by programmist_NA on 13.07.2020.
//

import Foundation

struct StoriesViewModel {
    struct Cell: StoriesCellViewModel, Hashable {
        var photoUrl: String
        var name: String
        var id: String
        var ownerId: String
        var date: String
        var expiresAt: String?
        var seen: Int
    }
    var cells: [Cell]
    let footerTitle: String?
}

protocol StoriesCellViewModel {
    var photoUrl: String { get }
    var name: String { get }
    var id: String { get }
    var ownerId: String { get }
    var date: String { get }
    var expiresAt: String? { get }
    var seen: Int { get }
}
