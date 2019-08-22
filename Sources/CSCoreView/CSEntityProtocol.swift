//
//  CSEntityProtocol.swift
//  CSCoreDB
//
//  Created by Georgie Ivanov on 22.08.19.
//

import Foundation
import CSCoreDB

public protocol CSEntityProtocol: CSDBEntityProtocol {
    associatedtype Entity: CSEntityProtocol
    static var singleName: String { get }
    static var pluralName: String { get }
    static var registerName: String { get }
    static func view() throws -> CSView<Entity>
    
    var id: Int { get set }
}
public extension CSEntityProtocol {
    static func view() throws -> CSView<Entity> {
        return try CSView<Entity>(dbConfiguration: CSCoreDBConfig.dbConfiguration)
    }
}

