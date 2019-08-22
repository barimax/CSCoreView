//
//  CSView.swift
//  CSCoreDB
//
//  Created by Georgie Ivanov on 18.08.19.
//
import Foundation
import PerfectCRUD
import PerfectMySQL
import CSCoreDB

public class CSView<E: CSEntityProtocol>: CSViewProtocol, CSDatabaseProtocol {
    public required convenience init() {
        try! self.init(dbConfiguration: CSCoreDBConfig.dbConfiguration)
    }
    public typealias Entity = E
    public let singleName: String = Entity.singleName
    public let pluralName: String = Entity.pluralName
    public let registerName: String = Entity.registerName
    
    public var db: Database<MySQLDatabaseConfiguration>
    public var table: Table<E, Database<MySQLDatabaseConfiguration>>
  
    public var entity: Entity?
    public var rows: [Entity]?
    
    public func json() throws -> String {
        throw CSViewError.jsonError
    }
    
    public init(dbConfiguration c: CSCoreDB?) throws {
        var dbConfiguration: CSCoreDB
        if let uc = c {
            dbConfiguration = uc
        }else{
            dbConfiguration = CSCoreDB (
                host: "127.0.0.1",
                username: "bmserver",
                password: "B@r1m@x2016",
                database: "bmMySqlDB"
            )
        }
        self.db = try Database(
            configuration: MySQLDatabaseConfiguration(
                database: dbConfiguration.database,
                host: dbConfiguration.host,
                port: dbConfiguration.port,
                username: dbConfiguration.username,
                password: dbConfiguration.password
            )
        )
        self.table = db.table(Entity.self)
    }
}

