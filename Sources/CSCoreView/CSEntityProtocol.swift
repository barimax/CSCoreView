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
    static func view() -> CSView<Entity>
    
    var id: Int { get set }
}
extension CSEntityProtocol {
    static func view() -> CSView<Entity> {
        return CSView<Entity>()
    }
}

