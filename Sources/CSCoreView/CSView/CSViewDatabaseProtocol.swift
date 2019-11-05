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
    var registerName: String { Entity.registerName }
    var singleName: String { Entity.singleName }
    var pluralName: String { Entity.pluralName }
    var fields: [CSPropertyDescription] { Entity.fields }
    var searchableFields: [AnyKeyPath] { Entity.searchableFields }
}

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
public extension CSViewDatabaseProtocol where Self.Entity: CSMTMProtocol {
    func createRefTypes() throws {
        for (_, type) in Entity.mtmRefs {
            let createTableQuery = """
            CREATE TABLE IF NOT EXISTS `\(type.tableName)` (
            `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
            `firstId` bigint(20) UNSIGNED NOT NULL,
            `secondId` bigint(20) UNSIGNED NOT NULL,
            PRIMARY KEY (`id`))
            """
            try Entity.view().db?.sql(createTableQuery)
        }
    }
    private func makeGetQuery(whereStirng: String = "") throws -> String {
        let mainTableName = Entity.tableName
        var select = "SELECT m.* "
        let from = "FROM \(mainTableName) AS m "
        var join = ""
        let groupBy = " GROUP BY m.id"
        var joinNum = 0
        for field in Entity.fields {
            if let keyPath = field.keyPath as? KeyPath<Entity, [UInt64]?>, let mtm = Entity.mtmRefs as? [KeyPath<Entity, [UInt64]?>: CSMTMRefProtocol.Type], let refType = mtm[keyPath]  {
                joinNum += 1
                let refTableName = refType.tableName
                if refType.firstIdType.registerName == refType.secondIdType.registerName {
                    throw CSCoreDBError.joinError
                }
                if let joinType = field.ref as? TableNameProvider.Type {
                    let joinTableName = joinType.tableName
                    
                    
                    let f = refType.firstIdType.registerName == Entity.registerName ? "firstId" : "secondId"
                    let s = f == "firstId" ? "secondId" : "firstId"
                    
                    select += ", IF(GROUP_CONCAT(DISTINCT j\(joinNum).id) IS NULL, \"[]\", CONCAT(\"[\", GROUP_CONCAT(DISTINCT j\(joinNum).id), \"]\")) AS \(field.name) "
                    join += " " + """
                    LEFT JOIN \(refTableName) AS r\(joinNum) ON r\(joinNum).\(f) = m.id
                    LEFT JOIN \(joinTableName) AS j\(joinNum) ON j\(joinNum).id = r\(joinNum).\(s)
                    """
                }
            }
        }
        return select + from + join + " " + whereStirng + " " + groupBy
    }
    func getAll() throws -> [CSEntityProtocol]  {
        guard let rows = try Entity.view().db?.sql(self.makeGetQuery(), Entity.self) else {
            throw CSCoreDBError.joinError
        }
        return rows
    }
    func get(id: UInt64) throws -> CSEntityProtocol {
        guard let e = try Entity.view().db?.sql(self.makeGetQuery(whereStirng: "WHERE m.id = \(id)"), Entity.self).first else {
            throw CSCoreDBError.joinError
        }
        return e
    }
    func save(entity: CSEntityProtocol) throws -> CSEntityProtocol {
        guard var dbEntity = entity as? Entity, let currentConnection = self.db else {
            throw CSCoreDBError.joinError
        }
        if dbEntity.id > 0 {
            try currentConnection.transaction {
                for field in self.fields {
                    if let keyPath = field.keyPath as? KeyPath<Entity, [UInt64]?>, let mtm = Entity.mtmRefs as? [KeyPath<Entity, [UInt64]?>: CSMTMRefProtocol.Type], let refType = mtm[keyPath] {
                        if refType.firstIdType.registerName == refType.secondIdType.registerName {
                            throw CSCoreDBError.joinError
                        }
                        let refField = refType.firstIdType.registerName == Entity.registerName ? "firstId" : "secondId"
                        let joinField = refField == "firstId" ? "secondId" : "firstId"
                        try currentConnection.sql("DELETE FROM \(refType.tableName) WHERE \(refField) = \(dbEntity.id)")
                        guard let keyPath = field.keyPath as? KeyPath<Entity, [UInt64]> else {
                            throw CSCoreDBError.joinError
                        }
                        for v in dbEntity[keyPath: keyPath] {
                            try currentConnection.sql(
                                """
                                INSERT INTO \(refType.tableName)
                                (id, \(refField), \(joinField))
                                VALUES (0, \(dbEntity.id), \(v) )
                                """
                            )
                        }
                    }
                }
                try currentConnection.table(Entity.self).update(dbEntity)
            }
            return try self.get(id: dbEntity.id)
        }else{
            try currentConnection.transaction {
                guard let newId: UInt64 = try currentConnection.table(Entity.self).insert(dbEntity).lastInsertId() else {
                    throw CSCoreDBError.joinError
                }
                dbEntity.id = newId
                for field in self.fields {
                    if let keyPath = field.keyPath as? KeyPath<Entity, [UInt64]?>, let mtm = Entity.mtmRefs as? [KeyPath<Entity, [UInt64]?>: CSMTMRefProtocol.Type], let refType = mtm[keyPath] {
                        if refType.firstIdType.registerName == refType.secondIdType.registerName {
                            throw CSCoreDBError.joinError
                        }
                        let refField = refType.firstIdType.registerName == Entity.registerName ? "firstId" : "secondId"
                        let joinField = refField == "firstId" ? "secondId" : "firstId"
                        guard let keyPath = field.keyPath as? KeyPath<Entity, [UInt64]?>,
                            let values = dbEntity[keyPath: keyPath] else {
                            throw CSCoreDBError.joinError
                        }
                        
                        for v in values {
                            try currentConnection.sql(
                                """
                                INSERT INTO \(refType.tableName)
                                (id, \(refField), \(joinField))
                                VALUES (0, \(dbEntity.id), \(v) )
                                """
                            )
                        }
                    }
                }
            }
            return try self.get(id: dbEntity.id)
        }
    }
    func delete(_ id: UInt64) throws {
        guard let currentConnection = self.db else {
            throw CSCoreDBError.joinError
        }
        try currentConnection.transaction {
            for field in self.fields {
                if let keyPath = field.keyPath as? KeyPath<Entity, [UInt64]?>, let mtm = Entity.mtmRefs as? [KeyPath<Entity, [UInt64]?>: CSMTMRefProtocol.Type], let refType = mtm[keyPath] {
                    if refType.firstIdType.registerName == refType.secondIdType.registerName {
                        throw CSCoreDBError.joinError
                    }
                    let refField = refType.firstIdType.registerName == Entity.registerName ? "firstId" : "secondId"
                    try currentConnection.sql("DELETE FROM \(refType.tableName) WHERE \(refField) = \(id)")
                }
            }
            try currentConnection.table(Entity.self).where(\Entity.id == id).delete()
        }
    }
    func find(criteria: [String: Any]) -> [CSEntityProtocol] {
        if criteria.count > 0 {
            var whereString: String = "WHERE "
            var i: Int = 0
            for (key, value) in criteria {
                if i > 0 {
                    whereString += "AND "
                }
                whereString += "m.\(key) = '\(value)' "
                i += 1
            }
            if let r = try? Entity.view().db?.sql(self.makeGetQuery(whereStirng: whereString), Entity.self) {
                return r
            }
        }
        return []
    }
    func search(query: String) -> [CSEntityProtocol] {
        let view = Entity.view()
        if view.searchableFields.count > 0 {
            var whereString: String = "WHERE "
            var i: Int = 0
            for sField in view.searchableFields {
                for field in self.fields {
                    if field.keyPath == sField {
                        if i > 0 {
                            whereString += "OR "
                        }
                        whereString += "m.\(field.name) LIKE '%\(query)%' "
                        i += 1
                    }
                }
            }
            if i == 0 {
                return []
            }
            if let r = try? view.db?.sql(self.makeGetQuery(whereStirng: whereString), Entity.self) {
                return r
            }
        }
        return []
    }
}

