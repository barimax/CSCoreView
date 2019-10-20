//
//  Register.swift
//  CSCoreDB
//
//  Created by Georgie Ivanov on 18.08.19.
//

import Foundation

public protocol CSRegisterProtocol {
    static var store: [String: CSEntityProtocol.Type] { get set }
    static func setup() throws
}
public extension CSRegisterProtocol {
    static func add(forKey: String, type: CSEntityProtocol.Type) {
        Self.store[forKey] = type
    }
    static func getView(forKey: String) throws -> CSViewProtocol {
        guard let type = Self.store[forKey] else {
            throw CSViewError.registerError(message: "Not found type")
        }
        return type.view()
    }
    static func setup() throws {
        for (_, entity) in CSRegister.store {
            let view = entity.view()
            try view.create()
            if let mtm = view as? CSMTMProtocol {
                try mtm.createRefTypes()
            }
        }
    }
}
public struct CSRegister: CSRegisterProtocol {
    public static var store: [String: CSEntityProtocol.Type] = [:]
}


