//
//  CSView.swift
//  CSCoreDB
//
//  Created by Georgie Ivanov on 18.08.19.
//
import Foundation
import PerfectCRUD
import PerfectMySQL


public struct CSView: CSViewDatabaseProtocol {
    
    public typealias Entity = TestEntity
    public var singleName: String = ""
    public var pluralName: String = ""
    public var fields: [CSPropertyDescription] = []
    public static var registerName: String = ""
    
    public var searchableFields: [AnyKeyPath] {
        []
    }
}
public struct TestEntity: CSEntityProtocol {
    public static var tableName: String = ""
    public var id: UInt64 = 0
    public static func view() -> CSViewProtocol {
        CSView()
    }
}

