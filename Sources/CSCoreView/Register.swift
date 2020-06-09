//
//  Register.swift
//  CSCoreDB
//
//  Created by Georgie Ivanov on 18.08.19.
//

import Foundation
import PerfectMySQL

public class CSRegister {
    public static var store: [String: CSEntityProtocol.Type] = [:]
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
    public static func setup(withDatabase db: String, host h: String, username u: String, password p: String, port o: Int = 3306) throws {
        let mysql = MySQL()
        let connected = mysql.connect(host: h, user: u, password: p, db: nil, port: UInt32(o))
        guard connected else {
            throw CSCoreDBError.connectionError
        }
        let result = mysql.query(statement: "CREATE DATABASE IF NOT EXISTS `\(db)` CHARACTER SET utf8 COLLATE utf8_general_ci")
        guard result else {
            throw CSCoreDBError.databaseError
        }
        for (_, entity) in CSRegister.store {
            let view = entity.view(db)
            try view.create()
        }
    }
}
