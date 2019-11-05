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
    associatedtype Entity: CSEntityProtocol
    var db: Database<MySQLDatabaseConfiguration>? { get }
    var table: Table<Entity, Database<MySQLDatabaseConfiguration>>? { get }
    var database: String? { get set }
}
public extension CSDatabaseProtocol {
    var table: Table<Entity, Database<MySQLDatabaseConfiguration>>? {
        self.db?.table(Entity.self)
    }
    var db: Database<MySQLDatabaseConfiguration>? {
        guard let dbName = self.database else {
            return nil
        }
        let dbConfiguration = CSCoreDB (
            host: "127.0.0.1",
            username: "bmserver",
            password: "B@r1m@x2016",
            database: dbName
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
}

