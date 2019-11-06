//
//  CSDatabaseProtocol.swift
//  CSCoreDB
//
//  Created by Georgie Ivanov on 18.08.19.
//

import Foundation
import PerfectCRUD
import PerfectMySQL

protocol CSDatabaseProtocol {
    associatedtype Entity: CSEntityProtocol
    var db: Database<MySQLDatabaseConfiguration>? { get }
    var table: Table<Entity, Database<MySQLDatabaseConfiguration>>? { get }
    var database: String { get }
}
extension CSDatabaseProtocol {
    var table: Table<Entity, Database<MySQLDatabaseConfiguration>>? {
        self.db?.table(Entity.self)
    }
    var db: Database<MySQLDatabaseConfiguration>? {
        let dbConfiguration = CSCoreDB (database: self.database)
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

