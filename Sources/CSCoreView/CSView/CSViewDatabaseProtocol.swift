//
//  CSViewDatabaseProtocol.swift
//  CSCoreView
//
//  Created by Georgie Ivanov on 20.10.19.
//

import Foundation
import PerfectCRUD
import PerfectMySQL

public protocol CSViewDatabaseProtocol: CSViewProtocol, CSDatabaseProtocol {}
public extension CSViewDatabaseProtocol {
    static var tableName: String {
        Entity.tableName
    }
    func create() throws {
        print(type(of: Entity.self))
        try self.db?.create(Entity.self, policy: .shallow)
    }
    
    func getAll() throws -> [CSEntityProtocol] {
        guard let entities = try self.table?.select().map({ $0 }) else {
            throw CSCoreDBError.entityNotFound
        }
        return entities
    }
    func get(id: UInt64) throws -> CSEntityProtocol {
        guard let entity: Entity = try self.table?.where(\Entity.id == id).first() else {
            throw CSCoreDBError.entityNotFound
        }
        return entity
    }
    func save(entity: CSEntityProtocol) throws -> CSEntityProtocol {
        guard var newEntity = entity as? Entity else {
            throw CSCoreDBError.saveError(message: "Not entity")
        }
        if newEntity.id > 0 {
            
            try self.table?.where(\Entity.id == newEntity.id).update(newEntity)
        }else{
            guard let newId: UInt64 = try self.table?.insert(newEntity).lastInsertId() else {
                throw CSCoreDBError.saveError(message: "No new ID.")
            }
            newEntity.id = newId
        }
        return newEntity
    }
    func delete(id: UInt64) throws {
        try self.table?.where(\Entity.id == id).delete()
    }
}

