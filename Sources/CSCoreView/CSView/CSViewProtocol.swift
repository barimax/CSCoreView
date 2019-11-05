//
//  CSViewProtocol.swift
//  CSCoreDB
//
//  Created by Georgie Ivanov on 18.08.19.
//
import Foundation
import PerfectCRUD
import PerfectMySQL

public protocol CSViewProtocol:  TableNameProvider, Encodable {
    var registerName: String { get }
    var refs: [String:String] { get }
    var singleName: String { get }
    var pluralName: String { get }
    var fields: [CSPropertyDescription] { get }
    var searchableFields: [AnyKeyPath] { get }
    var refOptions: [String:CSRefOptionField] { get }
    var backRefs: [CSBackRefs] { get }
    
    var db: Database<MySQLDatabaseConfiguration>? { get }
    var database: String { get }
    
    func create() throws
    func getAll() throws -> [CSEntityProtocol]
    func get(id: UInt64) throws -> CSEntityProtocol
    func save(entity: CSEntityProtocol) throws -> CSEntityProtocol
    func delete(id: UInt64) throws
    func find(criteria: [String: Any]) -> [CSEntityProtocol]
    func search(query: String) -> [CSEntityProtocol]
    
    
    
    func toJSON() throws -> String
    func encode(to encoder: Encoder) throws
}
public extension CSViewProtocol {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CSViewCodingKeys.self)
        try container.encode(refs, forKey: .refs)
        try container.encode(singleName, forKey: .singleName)
        try container.encode(pluralName, forKey: .pluralName)
        try container.encode(fields, forKey: .fields)
        try container.encode(refOptions, forKey: .refOptions)
        try container.encode(backRefs, forKey: .backRefs)
        try container.encode(registerName, forKey: .singleName)
    }
    func toJSON() throws -> String {
        guard let str = try String(data: JSONEncoder().encode(self), encoding: .utf8) else {
            throw CSViewError.jsonError
        }
        return str
    }
}
enum CSViewCodingKeys: String, CodingKey {
    case refs, singleName, pluralName, fields, refOptions, backRefs, registerName
}


