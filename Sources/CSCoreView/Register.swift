//
//  Register.swift
//  CSCoreDB
//
//  Created by Georgie Ivanov on 18.08.19.
//

import Foundation

public class CSRegister {
    static var store: [String: CSEntityProtocol.Type] = [:]
    public static func add(forKey: String, type: CSEntityProtocol.Type) {
        Self.store[forKey] = type
    }
    public static func getView(forKey: String) throws -> CSViewProtocol {
        guard let type = Self.store[forKey] else {
            throw CSViewError.registerError(message: "Not found type")
        }
        return type.view()
    }
    public static func getType(forKey: String) throws -> CSEntityProtocol.Type {
        guard let type = Self.store[forKey] else {
            throw CSViewError.registerError(message: "Not found type")
        }
        return type
    }
    public static func setup() throws {
        for (_, entity) in CSRegister.store {
            let view = entity.view()
            try view.create()
            if let mtm = view as? CSMTMProtocol {
                try mtm.createRefTypes()
            }
        }
    }
}


