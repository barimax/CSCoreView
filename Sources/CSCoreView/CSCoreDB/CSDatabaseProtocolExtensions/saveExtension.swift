//
//  saveExtension.swift
//  CSCoreDB
//
//  Created by Georgie Ivanov on 18.08.19.
//

import PerfectCRUD

public extension CSDatabaseProtocol {
    public static func save(entity: Any) throws -> Entity {
        guard var newEntity: Entity = entity as? Entity else {
            throw CSCoreDBError.saveError(message: "Found nil")
        }
        if newEntity.id > 0 {
            try Self.table?.where(\Entity.id == newEntity.id).update(newEntity)
        }else{
            guard let newId: UInt64 = try Self.table?.insert(newEntity).lastInsertId() else {
                throw CSCoreDBError.saveError(message: "No new ID.")
            }
            print(newId)
            newEntity.id = newId
        }
        return newEntity
    }
}
