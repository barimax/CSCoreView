//
//  CSView.swift
//  CSCoreDB
//
//  Created by Georgie Ivanov on 18.08.19.
//
import Foundation
import PerfectCRUD
import PerfectMySQL


public struct CSView<E: CSEntityProtocol>: CSViewDatabaseProtocol {
    public typealias Entity = E
    public var database: String?
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

