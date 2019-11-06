//
//  CSManyToManyProtocol.swift
//  CSCoreView
//
//  Created by Georgie Ivanov on 18.09.19.
//
import PerfectCRUD
import PerfectMySQL

public protocol CSMTMRefProtocol: Codable {
    static var tableName: String { get }
    static var firstIdType: CSOptionableProtocol.Type { get }
    static var secondIdType: CSOptionableProtocol.Type { get }
    var id: UInt64 { get }
    var firstId: UInt64 { get }
    var secondId: UInt64 { get }
}
public protocol CSMTMProtocol: CSEntityProtocol  {
    static var registerName: String { get }
    static var fields: [CSPropertyDescription] { get }
    static func view(_ db: String) -> CSViewProtocol
}
public protocol CSMTMEntityProtocol: CSMTMProtocol {
    static var mtmRefs: [KeyPath<Self, [UInt64]?>: CSMTMRefProtocol.Type] { get }
}
public extension CSMTMEntityProtocol {
    static func view(_ db: String) -> CSViewProtocol {
        return CSMTMView<Self>(db)
    }
}

protocol CSMTMDatabaseProtocol: CSViewDatabaseProtocol where Self.Entity: CSMTMEntityProtocol {}
extension CSMTMDatabaseProtocol {
    private func createRefTypes() throws {
        for (_, type) in Entity.mtmRefs {
            let createTableQuery = """
            CREATE TABLE IF NOT EXISTS `\(type.tableName)` (
            `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
            `firstId` bigint(20) UNSIGNED NOT NULL,
            `secondId` bigint(20) UNSIGNED NOT NULL,
            PRIMARY KEY (`id`))
            """
            try self.db?.sql(createTableQuery)
        }
    }
    func create() throws {
        guard let connection = self.db else {
            throw CSCoreDBError.connectionError
        }
        try connection.transaction {
            try self.db?.create(Entity.self, policy: .shallow)
            try self.db?.sql("ALTER TABLE \(Entity.tableName) MODIFY COLUMN id BIGINT UNSIGNED AUTO_INCREMENT")
            try self.createRefTypes()
        }
    }
    private func makeGetQuery(whereStirng: String = "") throws -> String {
        let mainTableName = Entity.tableName
        var select = "SELECT m.* "
        let from = "FROM \(mainTableName) AS m "
        var join = ""
        let groupBy = " GROUP BY m.id"
        var joinNum = 0
        for field in self.fields {
            if let keyPath = field.keyPath as? KeyPath<Entity, [UInt64]?>, let refType = Entity.mtmRefs[keyPath]  {
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
        guard let rows = try self.db?.sql(self.makeGetQuery(), Entity.self) else {
            throw CSCoreDBError.joinError
        }
        return rows
    }
    func get(id: UInt64) throws -> CSEntityProtocol {
        guard let e = try self.db?.sql(self.makeGetQuery(whereStirng: "WHERE m.id = \(id)"), Entity.self).first else {
            throw CSCoreDBError.joinError
        }
        print("here")
        return e
    }
    func save(entity: CSEntityProtocol) throws -> CSEntityProtocol {
        guard var dbEntity = entity as? Entity, let currentConnection = self.db else {
            throw CSCoreDBError.joinError
        }
        if dbEntity.id > 0 {
            try currentConnection.transaction {
                for field in self.fields {
                    if let keyPath = field.keyPath as? KeyPath<Entity, [UInt64]?>, let refType = Entity.mtmRefs[keyPath] {
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
                    if let keyPath = field.keyPath as? KeyPath<Entity, [UInt64]?>, let refType = Entity.mtmRefs[keyPath] {
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
                if let keyPath = field.keyPath as? KeyPath<Entity, [UInt64]?>, let refType = Entity.mtmRefs[keyPath] {
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
            if let r = try? self.db?.sql(self.makeGetQuery(whereStirng: whereString), Entity.self) {
                return r
            }
        }
        return []
    }
    func search(query: String) -> [CSEntityProtocol] {
        if self.searchableFields.count > 0 {
            var whereString: String = "WHERE "
            var i: Int = 0
            for sField in self.searchableFields {
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
            if let r = try? self.db?.sql(self.makeGetQuery(whereStirng: whereString), Entity.self) {
                return r
            }
        }
        return []
    }
}
