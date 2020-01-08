//
//  CSViewDatabaseProtocol.swift
//  CSCoreView
//
//  Created by Georgie Ivanov on 20.10.19.
//

import Foundation
import PerfectCRUD
import PerfectMySQL

protocol CSViewDatabaseProtocol: CSViewProtocol, CSDatabaseProtocol {}

extension CSViewDatabaseProtocol {
    var registerName: String { return Entity.registerName }
    var singleName: String { return Entity.singleName }
    var pluralName: String { return Entity.pluralName }
    var fields: [CSPropertyDescription] { return Entity.fields }
    var searchableFields: [AnyKeyPath] { return Entity.searchableFields }
}

extension CSViewDatabaseProtocol  {
    static var tableName: String {
        return Entity.tableName
    }
    func create() throws {
        for f in Entity.fields {
            if f.fieldType == .dynamicFormControl {
                if !(f.ref is CSDynamicFieldProtocol.Type) {
                    throw CSViewError.dynamicFieldError
                }
            }
        }
        try self.db?.create(Entity.self, policy: .shallow)
        try self.db?.sql("ALTER TABLE \(Entity.tableName) MODIFY COLUMN id BIGINT UNSIGNED AUTO_INCREMENT")
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
