//
//  CSManyToManyProtocol.swift
//  CSCoreView
//
//  Created by Georgie Ivanov on 18.09.19.
//
import PerfectCRUD
import PerfectMySQL

public protocol CSManyToManyRefProtocol: Codable {
    static var tableName: String { get }
    static var firstIdType: CSOptionableProtocol.Type { get }
    static var secondIdType: CSOptionableProtocol.Type { get }
    var id: UInt64 { get }
    var firstId: UInt64 { get }
    var secondId: UInt64 { get }
}



public protocol CSManyToManyProtocol {
    static var tableName: String { get }
    static var fields: [CSPropertyDescription] { get }
    static func createRefTypes() throws
    static func getAll() throws -> [CSManyToManyProtocol]
    static func get(id: UInt64) throws -> CSManyToManyProtocol
    static func save(entity: CSManyToManyProtocol) throws -> CSManyToManyProtocol
    static func delete(_ id: UInt64) throws
    static func find(criteria: [String: Any]) -> [CSManyToManyProtocol]
    static func search(query: String) -> [CSManyToManyProtocol]
}
public protocol CSManyToManyEntityProtocol: CSManyToManyProtocol {
    associatedtype Entity: CSEntityProtocol
    static var manyToManyRefs: [KeyPath<Entity, [UInt64]?>: CSManyToManyRefProtocol.Type] { get }
}
public extension CSManyToManyEntityProtocol {
    static func createRefTypes() throws {
        for (_, type) in Self.manyToManyRefs {
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
    private static func makeGetQuery(whereStirng: String = "") throws -> String {
        let mainTableName = Self.tableName
        var select = "SELECT m.* "
        let from = "FROM \(mainTableName) AS m "
        var join = ""
        let groupBy = " GROUP BY m.id"
        var joinNum = 0
        for field in Self.fields {
            if let keyPath = field.keyPath as? KeyPath<Entity, [UInt64]?>, let refType = Self.manyToManyRefs[keyPath]  {
                joinNum += 1
                let refTableName = refType.tableName
                if refType.firstIdType.registerName == refType.secondIdType.registerName {
                    throw CSCoreDBError.joinError
                }
                if let joinType = field.ref as? TableNameProvider.Type {
                    let joinTableName = joinType.tableName
                    
                    
                    let f = refType.firstIdType.registerName == mainTableName ? "firstId" : "secondId"
                    let s = refType.secondIdType.registerName == joinTableName ? "secondId" : "firstId"
                    
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
    static func getAll() throws -> [CSManyToManyProtocol] {
        if let r = try Entity.view().db?.sql(Self.makeGetQuery(), Entity.self) as? [CSManyToManyProtocol] {
            return r
        }
        return []
    }
    static func get(id: UInt64) throws -> CSManyToManyProtocol {
        guard let e = try Entity.view().db?.sql(Self.makeGetQuery(whereStirng: "WHERE m.id = \(id)"), Entity.self).first as? CSManyToManyProtocol else {
            throw CSCoreDBError.joinError
        }
        return e
    }
    static func save(entity: CSManyToManyProtocol) throws -> CSManyToManyProtocol {
        guard var dbEntity = entity as? Entity, let currentConnection = Entity.view().db else {
            throw CSCoreDBError.joinError
        }
        if dbEntity.id > 0 {
            try currentConnection.transaction {
                for field in Self.fields {
                    if let keyPath = field.keyPath as? KeyPath<Entity, [UInt64]?>, let refType = Self.manyToManyRefs[keyPath] {
                        if refType.firstIdType.registerName == refType.secondIdType.registerName {
                            throw CSCoreDBError.joinError
                        }
                        let refField = refType.firstIdType.registerName == Self.tableName ? "firstId" : "secondId"
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
            return try Self.get(id: dbEntity.id)
        }else{
            try currentConnection.transaction {
                guard let newId: UInt64 = try currentConnection.table(Entity.self).insert(dbEntity).lastInsertId() else {
                    throw CSCoreDBError.joinError
                }
                dbEntity.id = newId
                for field in Self.fields {
                    if let keyPath = field.keyPath as? KeyPath<Entity, [UInt64]?>, let refType = Self.manyToManyRefs[keyPath] {
                        if refType.firstIdType.registerName == refType.secondIdType.registerName {
                            throw CSCoreDBError.joinError
                        }
                        let refField = refType.firstIdType.registerName == Self.tableName ? "firstId" : "secondId"
                        let joinField = refField == "firstId" ? "secondId" : "firstId"
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
            }
            return try Self.get(id: dbEntity.id)
        }
    }
    static func delete(_ id: UInt64) throws {
        guard let currentConnection = Entity.view().db else {
            throw CSCoreDBError.joinError
        }
        try currentConnection.transaction {
            for field in Self.fields {
                if let keyPath = field.keyPath as? KeyPath<Entity, [UInt64]?>, let refType = Self.manyToManyRefs[keyPath] {
                    if refType.firstIdType.registerName == refType.secondIdType.registerName {
                        throw CSCoreDBError.joinError
                    }
                    let refField = refType.firstIdType.registerName == Self.tableName ? "firstId" : "secondId"
                    try currentConnection.sql("DELETE FROM \(refType.tableName) WHERE \(refField) = \(id)")
                }
            }
            try currentConnection.table(Entity.self).where(\Entity.id == id).delete()
        }
    }
    static func find(criteria: [String: Any]) -> [CSManyToManyProtocol] {
        if criteria.count > 0 {
            var whereString: String = "WHERE "
            var i: Int = 0
            for (key, value) in criteria {
                if i > 0 {
                    whereString += "AND "
                }
                whereString += "\(key) = '\(value)' "
                i += 1
            }
            if let r = try? Entity.view().db?.sql(Self.makeGetQuery(whereStirng: whereString), Entity.self) as? [CSManyToManyProtocol] {
                return r 
            }
        }
        return []
    }
    static func search(query: String) -> [CSManyToManyProtocol] {
        let view = Entity.view()
        if view.searchableFields.count > 0 {
            var whereString: String = "WHERE "
            var i: Int = 0
            for sField in view.searchableFields {
                for field in Self.fields {
                    if field.keyPath == sField {
                        if i > 0 {
                            whereString += "OR "
                        }
                        whereString += "\(field.name) LIKE '%\(query)%' "
                        i += 1
                    }
                }
            }
            if i == 0 {
                return []
            }
            if let r = try? view.db?.sql(Self.makeGetQuery(whereStirng: whereString), Entity.self) as? [CSManyToManyProtocol] {
                return r
            }
        }
        return []
    }
}
