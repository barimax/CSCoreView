//
//  CSEntityProtocol.swift
//  CSCoreDB
//
//  Created by Georgie Ivanov on 22.08.19.
//

import Foundation
import PerfectCRUD

public protocol CSBaseEntityProtocol: Codable, TableNameProvider {
    static var refs: [String:String] { get }
    static var singleName: String { get }
    static var pluralName: String { get }
    static var registerName: String { get }
    static var fields: [CSPropertyDescription] { get }
    static var searchableFields: [AnyKeyPath] { get }
    static func view() -> CSView
    static func create() throws
    static func getAll() throws -> [CSBaseEntityProtocol]
    static func get(id: UInt64) throws -> CSBaseEntityProtocol
    static func save(entity: CSBaseEntityProtocol) throws -> CSBaseEntityProtocol
    static func delete(entityId id: UInt64) throws
    static func find(criteria: [String: Any]) -> [CSBaseEntityProtocol]
    static func search(query: String) -> [CSBaseEntityProtocol]
    var id: UInt64 { get set }
}

public protocol CSEntityProtocol: CSBaseEntityProtocol, CSDatabaseProtocol  {}
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
    static func create() throws {
        try Self.db?.create(Entity.self, policy: .shallow)
    }
    static func getAll() throws -> [CSBaseEntityProtocol] {
        guard let entities = try Self.table?.select().map({ $0 }) else {
            throw CSCoreDBError.entityNotFound
        }
        return entities
    }
    static func get(id: UInt64) throws -> CSBaseEntityProtocol {
        guard let entity = try Self.table?.where(\Self.id == id).first() else {
            throw CSCoreDBError.entityNotFound
        }
        return entity
    }
    static func save(entity: CSBaseEntityProtocol) throws -> CSBaseEntityProtocol {
        guard var newEntity = entity as? Entity else {
            throw CSCoreDBError.saveError(message: "Not correct type.")
        }
        if newEntity.id > 0 {
            try Self.table?.where(\Entity.id == newEntity.id).update(newEntity)
        }else{
            guard let newId: UInt64 = try Self.table?.insert(newEntity).lastInsertId() else {
                throw CSCoreDBError.saveError(message: "No new ID.")
            }
            newEntity.id = newId
        }
        return newEntity
    }
    static func delete(entityId id: UInt64) throws {
        try Self.table?.where(\Self.id == id).delete()
    }
}

