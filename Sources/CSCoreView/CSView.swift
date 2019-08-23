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
    var refOptions: [String : CSRefOptionField<E>] = [:]
    
    
    public required convenience init() {
        try! self.init(dbConfiguration: CSCoreDBConfig.dbConfiguration)
    }
    public typealias Entity = E
    public var registerName: String = Entity.registerName
    
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
    // Codable keys
    enum CodingKeys: String, CodingKey {
        case registerName, fields, refs, encodedRows, refOptions, entity, dynamicParentFieldName, singleName, pluralName, backRefs, isSP, spIdName, filteredRefOptions, isAllowedOptionsDelegate, isDocumentView, documentRecords, recordView, recordsFieldName, gen
    }
    // Encodable conformance
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(registerName, forKey: .registerName)
        try container.encode(entity, forKey: .entity)
        try container.encode(singleName, forKey: .singleName)
        try container.encode(pluralName, forKey: .pluralName)
    }
    
    // Decodable conformance
    public required convenience init(from decoder: Decoder) throws {
        try self.init(dbConfiguration: CSCoreDBConfig.dbConfiguration)
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.registerName = try values.decodeIfPresent(String.self,forKey: .registerName) ?? ""
//        self.refs = try values.decodeIfPresent([String:String].self,forKey: .refs) ?? [:]
//        self.encodedRows = try values.decodeIfPresent(String.self,forKey: .encodedRows) ?? ""
//        self.entity = try values.decodeIfPresent(String.self,forKey: .entity)
//        self.dynamicParentFieldName = try values.decodeIfPresent(String.self,forKey: .dynamicParentFieldName)
//        self.isSP = try values.decodeIfPresent(Bool.self,forKey: .isSP) ?? false
//        self.spIdName = try values.decodeIfPresent(String.self,forKey: .spIdName)
        
    }
}

