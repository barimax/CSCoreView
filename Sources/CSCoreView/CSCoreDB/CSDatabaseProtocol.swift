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
}
public extension CSDatabaseProtocol {
    var table: Table<Entity, Database<MySQLDatabaseConfiguration>>? {
        self.db?.table(Entity.self)
    }
    var db: Database<MySQLDatabaseConfiguration>? {
        var dbConfiguration = CSCoreDB (
            host: "127.0.0.1",
            username: "bmserver",
            password: "B@r1m@x2016",
            database: "bmMySqlDB"
        )
        if let dbConfig = CSCoreDBConfig.dbConfiguration {
            dbConfiguration = dbConfig
        }
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

