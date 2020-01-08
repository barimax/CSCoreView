//
//  Register.swift
//  CSCoreDB
//
//  Created by Georgie Ivanov on 18.08.19.
//

import Foundation
import PerfectMySQL

public class CSRegister {
    static var store: [String: CSEntityProtocol.Type] = [:]
//    static var store: [String: CSEntityProtocol.Type] = ["dynamicEntity": CSDynamicEntity.self]
    public static func add(forKey: String, type: CSEntityProtocol.Type) {
        CSRegister.store[forKey] = type
    }
    public static func getView(forKey: String, withDatabase db: String) throws -> CSViewProtocol {
        guard let type = CSRegister.store[forKey] else {
            throw CSViewError.registerError(message: "Not found type")
        }
        return type.view(db)
    }
    public static func getType(forKey: String) throws -> CSEntityProtocol.Type {
        guard let type = CSRegister.store[forKey] else {
            throw CSViewError.registerError(message: "Not found type")
        }
        return type
    }
    public static func setup(withDatabase db: String, configuration c: CSCoreDB) throws {
        let mysql = MySQL()
        let connected = mysql.connect(host: c.host, user: c.username, password: c.password, db: nil, port: UInt32(c.port))
        guard connected else {
            throw CSCoreDBError.connectionError
        }
        let result = mysql.query(statement: "CREATE DATABASE IF NOT EXISTS \(db)")
        guard result else {
            throw CSCoreDBError.databaseError
        }
        for (_, entity) in CSRegister.store {
            let view = entity.view(db)
            try view.create()
        }
    }
}
