//
//  CSViewRefOptions.swift
//  CSCoreDB
//
//  Created by Georgie Ivanov on 23.08.19.
//

import Foundation

struct CSRefOptionField<Entity: CSEntityProtocol>: Codable {
    let registerName: String
    let options: [Int:String]
    var isButton: Bool
    var view: CSView<Entity>?
}
struct CSBackRefs: Codable {
    var registerName: String = ""
    var formField: String = ""
    var names: [String:String] = [:]
    var singleName: String = ""
    var pluralName: String = ""
    var createNewByMultiple: Bool = false
    var createNewByMultipleFields: [String] = []
}
