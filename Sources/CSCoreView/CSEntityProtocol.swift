//
//  CSEntityProtocol.swift
//  CSCoreDB
//
//  Created by Georgie Ivanov on 22.08.19.
//

import Foundation
import PerfectCRUD

public protocol CSEntityProtocol: Codable, TableNameProvider {
    static var registerName: String { get }
    static var singleName: String { get }
    static var pluralName: String { get }
    static var fields: [CSPropertyDescription] { get }
    static var searchableFields: [AnyKeyPath] { get }
    static func view() -> CSViewProtocol
    
    var id: UInt64 { get set }
}
public extension CSEntityProtocol {
    static func view() -> CSViewProtocol {
        CSView<Self>()
    }
}
