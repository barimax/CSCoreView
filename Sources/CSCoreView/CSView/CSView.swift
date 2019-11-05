//
//  CSView.swift
//  CSCoreDB
//
//  Created by Georgie Ivanov on 18.08.19.
//
import Foundation
import PerfectCRUD
import PerfectMySQL


struct CSView<E: CSEntityProtocol>: CSViewDatabaseProtocol {
    public typealias Entity = E
    public let database: String
    
    init(_ db: String) {
        self.database = db
    }
}
struct CSMTMView<E: CSMTMEntityProtocol>: CSMTMDatabaseProtocol {
    
    public typealias Entity = E
    public let database: String
    
    init(_ db: String) {
        self.database = db
    }
}

public struct TestEntity: CSEntityProtocol {
    public static var registerName: String = "test"
    public static var singleName: String = "Test"
    public static var pluralName: String = "Tests"
    public static var fields: [CSPropertyDescription] = []
    public static var searchableFields: [AnyKeyPath] = []
    public static var tableName: String = "tests"
    public var id: UInt64 = 0
}

