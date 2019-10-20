//
//  CSViewProtocol.swift
//  CSCoreDB
//
//  Created by Georgie Ivanov on 18.08.19.
//
import Foundation
import PerfectCRUD
import PerfectMySQL

public protocol CSViewProtocol: TableNameProvider {
    var refs: [String:String] { get }
    static var registerName: String { get }
    var singleName: String { get }
    var pluralName: String { get }
    var fields: [CSPropertyDescription] { get }
    var searchableFields: [AnyKeyPath] { get }
    var refOptions: [String:CSRefOptionField] { get }
    var backRefs: [CSBackRefs] { get }
    
    var entity: CSEntityProtocol? { get set }
    var rows: [CSEntityProtocol] { get set }
    
    var db: Database<MySQLDatabaseConfiguration>? { get }
    func create() throws
    mutating func loadAll() throws
    mutating func load(id: UInt64) throws
    mutating func save(entity: CSEntityProtocol) throws
    mutating func delete(id: UInt64) throws
    mutating func delete() throws
    func find(criteria: [String: Any]) -> [CSEntityProtocol]
    func search(query: String) -> [CSEntityProtocol]
}

