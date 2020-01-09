//
//  CSCustomData.swift
//  CSCoreView
//
//  Created by Georgie Ivanov on 6.01.20.
//
import PerfectMySQL
import Foundation
import SwiftString

public class CSCustomData {
    public static func createCustomTypesTable(db: String) throws {
        let m = CSCustomData(database: db)
        try m.exec("CREATE TABLE IF NOT EXISTs `customTypes` (`id` bigint unsigned AUTO_INCREMENT, `name` varchar(255), `properties` text, PRIMARY KEY(`id`));", params: [])
    }
    let mysql: MySQL
    
    public init(database db: String) {
        self.mysql = MySQL()
        let _ = self.mysql.connect(
            host: CSCoreDBConfig.dbConfiguration?.host,
            user: CSCoreDBConfig.dbConfiguration?.username,
            password: CSCoreDBConfig.dbConfiguration?.password,
            db: db,
            port: UInt32(CSCoreDBConfig.dbConfiguration?.port ?? 3306)
        )
    }
    func exec(_ statement: String, params: [Any]) throws {
        let lastStatement = MySQLStmt(self.mysql)
        let _ = lastStatement.prepare(statement: statement)
        for p in params {
            lastStatement.bindParam("\(p)")
        }
        print(statement)
        if !lastStatement.execute() {
            throw CSCoreDBError.databaseError
        }
        let _ = lastStatement.results()
    }
    
    public func create(registerName: String, field fds: [CSDynamicEntityPropertyDescription]) throws {
        let _ = try? self.exec("BEGIN;", params: [])
        var stmt = "CREATE TABLE IF NOT EXISTS `\(registerName)` ("
        var addID: Bool = true
        var i: Int = 0
        for f in fds {
            if i != 0 {
                stmt += ", "
            }
            i += 1
            var field: String = "`\(f.name)` "
            if f.name == "id" || f.name == "ID" {
                field = "`id` BIGINT UNSIGNED AUTO_INCREMENT"
                addID = false
            }else{
                switch f.jsType {
                case .string :
                    field += "text"
                case .datetime :
                    field += "datetime"
                case .number :
                    field += "bigint(20)"
                case .array, .object :
                    field += "json"
                case .bool :
                    field += "tinyint(1)"
                case .float :
                    field += "double"
                }
            }
            stmt += field
        }
        if addID {
            if i != 0 { stmt += ", " }
            stmt += " `id` BIGINT UNSIGNED AUTO_INCREMENT"
        }
        stmt += ", PRIMARY KEY (`id`));"
        
        do {
            try self.exec(stmt, params: [])
            guard let encodedProperties: String = try String(data:JSONEncoder().encode(fds), encoding: .utf8) else {
                throw CSCoreDBError.jsonDataError
            }
            let newCustomTypeRecordStmt: String = "INSERT INTO customTypes (name, properties) VALUES (?, ?);"
            try self.exec(newCustomTypeRecordStmt, params: [registerName, encodedProperties])
            try self.exec("COMMIT;", params: [])
        } catch {
            try exec("DROP TABLE `\(registerName)`;", params: [])
            try self.exec("ROLLBACK;", params: [])
            print(error)
        }
        
    }
    
    public func save(json: String = "{\"name\":\"Test\",\"isBool\":true}") {
        
        guard var str = json.between("{", "}") else {
            print("error")
            return
        }
        
        if str.removeFirst() != "{" {
            print("error")
        }
        if str.removeLast() != "}" {
            print("error")
        }
        print(str)
        var arr = str.split(separator: ",")
        print(arr)
        for a in arr {
            var p = a.split(separator: ":")
            print(p[0].hasPrefix(" "))
            if p[0].hasPrefix(" ") { p[0].removeFirst() }
            print(p[0].hasPrefix(" "))
            print(p[0])
        }
    }
}
