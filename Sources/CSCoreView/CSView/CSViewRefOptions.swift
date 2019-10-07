//
//  CSViewRefOptions.swift
//  CSCoreDB
//
//  Created by Georgie Ivanov on 23.08.19.
//

import Foundation

public struct CSRefOptionField: Codable {
    public let registerName: String
    public let options: [UInt64:String]
    public var isButton: Bool
}
public struct CSBackRefs: Codable {
    var registerName: String = ""
    var formField: String = ""
    var names: [String:String] = [:] //???
    var singleName: String = ""
    var pluralName: String = ""
    var createNewByMultiple: Bool = false
    var createNewByMultipleFields: [String] = []
}
