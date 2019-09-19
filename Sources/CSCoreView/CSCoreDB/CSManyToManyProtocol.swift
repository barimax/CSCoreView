//
//  CSManyToManyProtocol.swift
//  CSCoreView
//
//  Created by Georgie Ivanov on 18.09.19.
//
import PerfectCRUD

//public protocol CSManyToManyRefProtocol {
//    var firstId: UInt64 { get }
//    var secondId: UInt64 { get }
//}

public protocol CSManyToManyRefProtocol: Codable {
    static var tableName: String { get }
    static var firstIdType: CSManyToManyProtocol.Type { get }
    static var secondIdType: CSManyToManyProtocol.Type { get }
    var id: UInt64 { get }
    var firstId: UInt64 { get }
    var secondId: UInt64 { get }
}

struct CSManyToManyRef<F: CSManyToManyProtocol, S: CSManyToManyProtocol> {
    
}

public protocol CSManyToManyProtocol {
    static var tableName: String { get }
    static var manyToManyRefs: [AnyKeyPath: CSManyToManyRefProtocol.Type] { get }
    static var fields: [CSPropertyDescription] { get }
    static func getAll() -> [CSBaseEntityProtocol]
}
public protocol CSManyToManyEntityProtocol: CSManyToManyProtocol, CSDatabaseProtocol {}
public extension CSManyToManyEntityProtocol {
    public static func getAll() throws -> [CSBaseEntityProtocol] {
        var res: [CSBaseEntityProtocol] = []
        for field in Self.fields {
            if let refType = Self.manyToManyRefs[field.keyPath]  {
                if refType.firstIdType.tableName == refType.secondIdType.tableName {
                    throw CSViewError.findError
                }
                if let joinType = field.ref as? CSManyToManyProtocol.Type {
                    let joinTableName = joinType.tableName
                    let refTableName = refType.tableName
                    let mainTableName = Self.tableName
                    let f = refType.firstIdType.tableName == mainTableName ? "firstId" : "secondId"
                    let s = refType.secondIdType.tableName == joinTableName ? "secondId" : "firstId"
                    
                    let query = """
                    SELECT m.*
                    FROM \(mainTableName) AS m
                    LEFT JOIN \(refTableName) AS r ON r.\(f) = m.id
                    LEFT JOIN \(joinTableName) AS j ON j.id = r.\(s)
                    """
                    try db?.sql(query)
                }
            }
        }
        return res
    }
}
