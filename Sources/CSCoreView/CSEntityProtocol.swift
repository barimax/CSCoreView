//
//  CSEntityProtocol.swift
//  CSCoreDB
//
//  Created by Georgie Ivanov on 22.08.19.
//

import Foundation
import PerfectCRUD
import PerfectMySQL

public protocol CSEntityProtocol: Codable, TableNameProvider {
    static var registerName: String { get }
    static var singleName: String { get }
    static var pluralName: String { get }
    static var fields: [CSPropertyDescription] { get set }
    static var searchableFields: [AnyKeyPath] { get }
    static func view(_ db: String) -> CSViewProtocol
    
    
    var id: UInt64 { get set }
//    var prevId: UInt64 { get set }
}
public extension CSEntityProtocol {
    static func view(_ db: String) -> CSViewProtocol {
        let view = CSView<Self>(db)
        return view
    }
}
public protocol CSEntitySaveProtocol: CSEntityProtocol {
    static func saveModifier(entity: inout CSEntityProtocol, view: CSViewProtocol)
}
