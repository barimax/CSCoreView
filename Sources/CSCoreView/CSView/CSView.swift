//
//  CSView.swift
//  CSCoreDB
//
//  Created by Georgie Ivanov on 18.08.19.
//
import Foundation
import PerfectCRUD
import PerfectMySQL


public struct CSView: CSViewProtocol {
    public var entity: TestEntity?
    public var rows: [TestEntity]?
    
    
    public typealias Entity = TestEntity
    public static var tableName: String = ""
    public var singleName: String = ""
    public var pluralName: String = ""
    public var fields: [CSPropertyDescription] = []
    public var registerName: String = ""
    
    public var searchableFields: [AnyKeyPath] {
        []
    }
}
public struct TestEntity: CSEntityProtocol {
    public var id: UInt64 = 0
    
    public static func view() -> CSView {
        CSView()
    }
    
    
}

