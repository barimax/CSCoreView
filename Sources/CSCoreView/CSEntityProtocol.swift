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
    static var fields: [CSPropertyDescription] { get }
    static func view() -> CSView
    static func getAll() throws -> [CSBaseEntityProtocol]
    static func get(id: Int) throws -> CSBaseEntityProtocol
    static func save(entity: CSBaseEntityProtocol) throws -> CSBaseEntityProtocol
}

public protocol CSEntityProtocol: CSBaseEntityProtocol, CSDatabaseProtocol where Entity: CSEntityProtocol {
    
}
public extension CSEntityProtocol {
    
    static func view() -> CSView {
        return CSView(entity: Entity.self)
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
    static func getAll() throws -> [CSBaseEntityProtocol] {
        return try Self.getAll() as! [CSBaseEntityProtocol]
    }
    static func get(id: Int) throws -> CSBaseEntityProtocol {
        return try Self.get(id: id) as! CSBaseEntityProtocol
    }
    static func save(entity: CSBaseEntityProtocol) throws -> CSBaseEntityProtocol {
        return try Self.save(entity: entity) as! CSBaseEntityProtocol
    }
}

