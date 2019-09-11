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
}

public protocol CSEntityProtocol: CSBaseEntityProtocol, CSDatabaseProtocol where Entity: CSEntityProtocol {
    
    
    static func getAll() throws -> [Self]
    static func get(id: Int) throws -> Self
    static func save(entity: Self) throws -> Self
    static func delete(entityId id: Int) throws
    
    var id: Int { get set }
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
}

