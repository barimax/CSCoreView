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
    
    mutating func loadAll() throws {
        guard let entities = try self.table?.select().map({ $0 }) else {
            throw CSCoreDBError.entityNotFound
        }
        self.rows = entities
    }
    mutating func load(id: UInt64) throws {
        guard let entity: Entity = try self.table?.where(\Entity.id == id).first() else {
            throw CSCoreDBError.entityNotFound
        }
        self.entity = entity
    }
    mutating func save(entity: CSEntityProtocol) throws {
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
        self.entity = newEntity
    }
    mutating func delete(id: UInt64) throws {
        try self.table?.where(\Entity.id == id).delete()
        self.entity = nil
    }
    mutating func delete() throws {
        guard let entity = self.entity else {
            throw CSCoreDBError.deleteError
        }
        try self.delete(id: entity.id)
    }
}
