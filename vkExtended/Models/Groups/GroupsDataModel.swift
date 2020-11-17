//
//  GroupsDataModel.swift
//  VKExt
//
//  Created by Ярослав Стрельников on 31.08.2020.
//

import Foundation
import UIKit

enum Groups {
    enum Model {
        struct Request {
            enum RequestType {
                case getGroups
                case getNextBatch
                case getMembers
            }
        }
        struct Response {
            enum ResponseType {
                case presentGroups(groups: GroupResponse)
                case presentFooterLoader
                case presentFooterError(message: String)
            }
        }
        struct ViewModel {
            enum ViewModelData {
                case displayGroups(groupsViewModel: GroupViewModel)
                case displayEvents(eventsViewModel: GroupViewModel)
                case displayMembers(groupMembersViewModel: GroupMembersViewModel)
                case displayAdminsGroups(adminsGroupsViewModel: GroupViewModel)
                case displayFooterLoader
                case displayFooterError(message: String)
            }
        }
    }
}

struct GroupViewModel {
    struct Cell: GroupCellViewModel {
        var id: Int
        var name: String
        var screenName: String?
        var isClosed: Int
        var type: String
        var isAdmin: Int?
        var adminLevel: Int?
        var isMember: Int?
        var isAdvertiser: Int?
        var activity: String?
        var photo50: String
        var photo100: String
        var photo200: String
        var verified: Int
    }
    
    var cells: [Cell]
    let footerTitle: String?
}

protocol GroupCellViewModel {
    var id: Int { get }
    var name: String { get }
    var screenName: String? { get }
    var isClosed: Int { get }
    var type: String { get }
    var isAdmin: Int? { get }
    var adminLevel: Int? { get }
    var isMember: Int? { get }
    var isAdvertiser: Int? { get }
    var activity: String? { get }
    var photo50: String { get }
    var photo100: String { get }
    var photo200: String { get }
    var verified: Int { get }
}

struct GroupMembersViewModel {
    struct Cell: GroupMembersCellViewModel {
        var id: Int
        var firstName: String
        var lastName: String
        var sex: Int
        var photo100: String
        var canWritePrivateMessage: Int
    }
    
    var cells: [Cell]
    let footerTitle: String?
}

protocol GroupMembersCellViewModel {
    var id: Int { get }
    var firstName: String { get }
    var lastName: String { get }
    var sex: Int { get }
    var photo100: String { get }
    var canWritePrivateMessage: Int { get }
}
