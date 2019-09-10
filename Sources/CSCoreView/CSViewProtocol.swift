//
//  CSViewProtocol.swift
//  CSCoreDB
//
//  Created by Georgie Ivanov on 18.08.19.
//
import Foundation
import PerfectCRUD

public protocol CSViewProtocol: Codable {
    var registerName: String { get }
    var singleName: String { get }
    var pluralName: String { get }
    var fields: [CSPropertyDescription] { get }
    var refOptions: [String:CSRefOptionField] { get }
    var backRefs: [CSBackRefs] { get }
}
//public extension CSViewProtocol {
//    public var singleName: String {
//        return Entity.singleName
//    }
//    public var pluralName: String {
//        return Entity.pluralName
//    }
//    public var fields: [CSPropertyDescription] {
//        return Entity.fields
//    }
//}
