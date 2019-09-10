//
//  CSEntityProtocol.swift
//  CSCoreDB
//
//  Created by Georgie Ivanov on 22.08.19.
//

import Foundation
import CSCoreDB

public protocol CSBaseEntityProtocol: CSDBEntityProtocol {
    static var refs: [String:String] { get }
    static var singleName: String { get }
    static var pluralName: String { get }
    static var registerName: String { get }
}

public protocol CSEntityProtocol: CSBaseEntityProtocol {
    associatedtype Entity: CSEntityProtocol
    static func view() throws -> CSView<Entity>
    static var fields: [CSPropertyDescription] { get }
    
    var id: Int { get set }
}
public extension CSEntityProtocol {
    static func view() throws -> CSView<Entity> {
        return try CSView<Entity>(dbConfiguration: CSCoreDBConfig.dbConfiguration)
    }
    static var refs: [String:String] {
        var res: [String:String] = [:]
        for field in self.fields {
            if let ref = field.ref {
                res[field.name] = ref.registerName
            }
        }
        return res
    }
}

