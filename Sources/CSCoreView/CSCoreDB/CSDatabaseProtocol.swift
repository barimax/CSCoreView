//
//  CSDatabaseProtocol.swift
//  CSCoreDB
//
//  Created by Georgie Ivanov on 18.08.19.
//

import Foundation
import PerfectCRUD
import PerfectMySQL

public protocol CSDatabaseProtocol {
    associatedtype Entity: CSDBEntityProtocol
    static var db: Database<MySQLDatabaseConfiguration>? { get }
    static var table: Table<Entity, Database<MySQLDatabaseConfiguration>>? { get }
    static func getAll() throws -> [Entity]
    static func get(id: UInt64) throws -> Entity
    static func save(entity: Any) throws -> Entity
    static func delete(entityId id: UInt64) throws
    static func equalExpression<E: Codable>(keyPath: KeyPath<E, String>, query: String) -> CRUDBooleanExpression
    static func likeExpression<E: Codable>(keyPath: KeyPath<E, String>, query: String) -> CRUDBooleanExpression
    static func orExpression(l: CRUDBooleanExpression, r: CRUDBooleanExpression) -> CRUDBooleanExpression
    static func andExpression(l: CRUDBooleanExpression, r: CRUDBooleanExpression) -> CRUDBooleanExpression
}
public extension CSDatabaseProtocol {
    public static var table: Table<Entity, Database<MySQLDatabaseConfiguration>>? {
        return Self.db?.table(Entity.self)
    }
    
    
    public static var db: Database<MySQLDatabaseConfiguration>? {
        let dbConfiguration = CSCoreDB (
            host: "127.0.0.1",
            username: "bmserver",
            password: "B@r1m@x2016",
            database: "bmMySqlDB"
        )
        return try? Database(
            configuration: MySQLDatabaseConfiguration(
                database: dbConfiguration.database,
                host: dbConfiguration.host,
                port: dbConfiguration.port,
                username: dbConfiguration.username,
                password: dbConfiguration.password
            )
        )
    }
    public static func equalExpression<E: Codable>(keyPath: KeyPath<E, String>, query: String) -> CRUDBooleanExpression {
        return keyPath == query
    }
    public static func likeExpression<E: Codable>(keyPath: KeyPath<E, String>, query: String) -> CRUDBooleanExpression {
        return keyPath %=% query
    }
    public static func orExpression(l: CRUDBooleanExpression, r: CRUDBooleanExpression) -> CRUDBooleanExpression {
        return l || r
    }
    public static func andExpression(l: CRUDBooleanExpression, r: CRUDBooleanExpression) -> CRUDBooleanExpression {
        return l && r
    }
}

