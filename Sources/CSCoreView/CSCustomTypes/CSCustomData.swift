//
//  CSCustomData.swift
//  CSCoreView
//
//  Created by Georgie Ivanov on 6.01.20.
//
import PerfectMySQL
import Foundation
import SwiftString

public struct CSCustomData {
//    public static func createCustomTypesTable(db: String) throws {
//        let m = CSCustomData(database: db)
//        try m.exec("CREATE TABLE IF NOT EXISTs `customTypes` (`id` bigint unsigned AUTO_INCREMENT, `name` varchar(255), `properties` text, PRIMARY KEY(`id`));", params: [])
//    }
    struct Response: Encodable {
        let view: [CSDynamicEntityPropertyDescription]
        let encodedEntity: String?
        let encodedRows: String?
        let registerName: String
    }
    let mysql: MySQL
    let properties: [CSDynamicEntityPropertyDescription]
    let registerName: String
    
    public init(database db: String, registerName: String) throws {
        self.mysql = MySQL()
        let _ = self.mysql.connect(
            host: CSCoreDBConfig.dbConfiguration?.host,
            user: CSCoreDBConfig.dbConfiguration?.username,
            password: CSCoreDBConfig.dbConfiguration?.password,
            db: db,
            port: UInt32(CSCoreDBConfig.dbConfiguration?.port ?? 3306)
        )
        guard let props = CSCustomData.selectPropertyDescriptions(registerName: registerName, mysql: self.mysql) else {
            throw CSCustomDataError.initError
        }
        self.registerName = registerName
        self.properties = props
    }
    private static func selectPropertyDescriptions(registerName: String, mysql: MySQL) -> [CSDynamicEntityPropertyDescription]? {
        var properties: [CSDynamicEntityPropertyDescription]? = nil
        let lastStatement = MySQLStmt(mysql)
        let _ = lastStatement.prepare(statement: "SELECT `properties` FROM `customTypes` WHERE `name` = ?;")
        lastStatement.bindParam("\(registerName)")
        let _ = lastStatement.execute()
        let result = lastStatement.results()
        let _ = result.forEachRow { row in
            if let rowString: String = row[0] as? String,
                let data = rowString.data(using: .utf8),
                let decoded = try? JSONDecoder().decode([CSDynamicEntityPropertyDescription].self, from: data){
                properties = decoded
            }
        }
        return properties
    }
    public static func create(registerName: String, fields: [CSDynamicEntityPropertyDescription], database db: String) throws {
        let mysql = MySQL()
        let _ = mysql.connect(
            host: CSCoreDBConfig.dbConfiguration?.host,
            user: CSCoreDBConfig.dbConfiguration?.username,
            password: CSCoreDBConfig.dbConfiguration?.password,
            db: db,
            port: UInt32(CSCoreDBConfig.dbConfiguration?.port ?? 3306)
        )
        var stmt = "CREATE TABLE `\(registerName)` ("
        var addID: Bool = true
        var i: Int = 0
        for f in fields {
            if i != 0 && f.fieldType != .multipleSelect {
                stmt += ", "
            }
            i += 1
            var field: String = "`\(f.name)` "
            if f.name == "id" || f.name == "ID" {
                field = "`id` BIGINT UNSIGNED AUTO_INCREMENT"
                addID = false
            }else if f.refRegisterName != nil {
                if f.fieldType == .select || f.fieldType == .dynamicFormControl {
                    field += "bigint(20)"
                }else if f.fieldType == .multipleSelect{
                    field = ""
                    let createRelationTableStmt = "CREATE TABLE IF NOT EXISTS \(registerName)_\(f.refRegisterName!) (`id` BIGINT UNSIGNED AUTO_INCREMENT, \(registerName)_id BIGINT UNSIGNED, \(f.refRegisterName!)_id BIGINT UNSIGNED, PRIMARY KEY (`id`));"
                    print(createRelationTableStmt)
                    try CSCustomData.exec(createRelationTableStmt, params: [], mysql: mysql)
                }else{
                    throw CSCustomDataError.createError
                }
            }else{
                switch f.jsType {
                case .string :
                    field += "text"
                case .datetime :
                    field += "datetime"
                case .number :
                    field += "bigint(20)"
                case .numbersArray, .object, .objectsArray :
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
        print(stmt)
        do {
            try? CSCustomData.exec("BEGIN", params: [], mysql: mysql)
            guard let encodedProperties: String = try String(data:JSONEncoder().encode(fields), encoding: .utf8) else {
                throw CSCoreDBError.jsonDataError
            }
            let newCustomTypeRecordStmt: String = "INSERT INTO customTypes (name, properties) VALUES (?, ?);"
            try CSCustomData.exec(newCustomTypeRecordStmt, params: [registerName, encodedProperties], mysql: mysql)
            let statement = MySQLStmt(mysql)
            if !statement.prepare(statement: stmt) {
                throw CSCustomDataError.mysqlCreateError(error: .prepare, message: statement.errorMessage())
            }
            if !statement.execute() {
                throw CSCustomDataError.mysqlCreateError(error: .execute, message: statement.errorMessage())
            }
        } catch CSCustomDataError.mysqlCreateError(error: _, message: let message) {
            print(message)
        } catch {
            try CSCustomData.exec("DROP TABLE `\(registerName)`;", params: [], mysql: mysql)
            print(error)
            throw CSCoreDBError.mysqlError(message: "\(error)")
        }
        
    }
    
    public func getAll() throws -> String? {
        let response: Response = Response(
            view: self.properties,
            encodedEntity: nil,
            encodedRows: try self.getFromMySQL(),
            registerName: self.registerName
        )
        return try String(data: JSONEncoder().encode(response), encoding: .utf8)
    }
    public func getAll(id: UInt64) throws -> String? {
        let response: Response = Response(
            view: self.properties,
            encodedEntity: try self.getFromMySQL(id: id),
            encodedRows: try self.getFromMySQL(),
            registerName: self.registerName
        )
        return try String(data: JSONEncoder().encode(response), encoding: .utf8)
    }
    
    public func get(id: UInt64) throws -> String? {
        let response: Response = Response(
            view: self.properties,
            encodedEntity: try self.getFromMySQL(id: id),
            encodedRows: nil,
            registerName: self.registerName
        )
        return try String(data: JSONEncoder().encode(response), encoding: .utf8)
    }
    
    public func save(json: String) throws -> String? {
        let response: Response = Response(
            view: self.properties,
            encodedEntity: try self.saveData(json: json),
            encodedRows: nil,
            registerName: self.registerName
        )
        return try String(data: JSONEncoder().encode(response), encoding: .utf8)
    }
    
    public func saveAndGet(json: String) throws -> String? {
        let response: Response = Response(
            view: self.properties,
            encodedEntity: try self.save(json: json),
            encodedRows: try self.getFromMySQL(),
            registerName: self.registerName
        )
        return try String(data: JSONEncoder().encode(response), encoding: .utf8)
    }
    private func stripIt(str: String) -> String {
        return self.stripEnd(str: self.stripStart(str: str))
    }
    private func stripStart(str: String) -> String {
        if let f = str.first,  f == "\"" || f == "\\" {
            return self.stripStart(str: str.substring(1, length: str.count - 1))
        }else{
            return str
        }
    }
    private func stripEnd(str: String) -> String {
        if let l = str.last, l == "\"" || l == "\\" {
            return self.stripEnd(str: str.substring(0, length: str.count - 2))
        }else{
            return str
        }
    }
    
    private func decode(jsonString json: String) throws -> [String: Any] {
        guard let str = json.between("{", "}") else {
            throw CSCustomDataError.notValidJSON
        }
        var res: [String] = []
        var sub: [Character] = []
        var inObj: Bool = false
        for char in str {
            if char == "[" || char == "{" { inObj = true }
            if char == "]" || char == "}" { inObj = false }
            if char != "," || inObj {
                sub.append(char)
            }else{
                res.append(String(sub))
                sub = []
            }
        }
        res.append(String(sub))
        var values: [String: Any] = [:]
        for a in res {
            print("f: \(a)")
            var r = a.split(separator: ":", maxSplits: 1)
            guard r.count == 2 else {
                throw CSCustomDataError.notValidJSON
            }
            // print(r)
            print("end")
            let p = String(r[0]).trimmed()
            let key = self.stripIt(str: p)
            let rawValue = String(r[1])
            for f in self.properties {
                if f.name == key {
                    var value: Any?
                    if key == "id" {
                        if let id = UInt64(rawValue), id > 0 {
                            value = id
                        }
                    }else{
                        switch f.jsType {
                        case .string, .datetime :
//                            print(rawValue)
//                            print(rawValue.first)
//                            if let rf = rawValue.first, rf == "\"", let rl = rawValue.last, rl == "\"" {
//                                value = String(rawValue).substring(1, length: (rawValue.count-2))
//                                print(value)
//                            }
                            value = stripIt(str: rawValue)
                        case .number :
                            value = Int(rawValue)
                        case .numbersArray, .object, .objectsArray :
                            value = rawValue
                        case .bool :
                            if let bool = rawValue.toBool() {
                                value = bool ? 1 : 0
                            }
                        case .float :
                            value = Double(rawValue)
                        }
                    }
                    guard let unwrapped = value else {
                        throw CSCustomDataError.notValidJSONValue(key: key)
                    }
                    values[key] = unwrapped
                } else if key == "id" {
                    guard let id = UInt64(rawValue) else {
                        throw CSCustomDataError.notValidJSONValue(key: key)
                    }
                    values[key] = id
                }
            }
        }
        return values
    }
    
    private func select(id: UInt64? = nil) -> [[Any?]] {
        let selectStatement = MySQLStmt(self.mysql)
        var hasJoin: Bool = false
        var selectStmt: String = ""
        var i = 0;
        var select: String = "SELECT `t1`.`id`"
        var join: String = ""
        for j in self.properties {
            if j.refRegisterName != nil && j.fieldType == .multipleSelect {
                select += ",CONCAT(\"[\",GROUP_CONCAT(`j\(i)`.`\(j.name)_id`),\"]\") AS `\(j.name)`"
                join += " LEFT JOIN `\(self.registerName)_\(j.refRegisterName!)` AS `j\(i)` ON `j\(i)`.`\(self.registerName)_id` = `t1`.`id`"
                hasJoin = true
            }else{
                select += ",`t1`.`\(j.name)`"
            }
            i += 1
        }
        selectStmt += (select + " FROM `\(self.registerName)` AS t1 " + join)
        if let thisId = id, thisId > 0 {
            selectStmt += " WHERE `t1`.`id` = ?"
        }
        if hasJoin {
            selectStmt += " GROUP BY `t1`.`id`"
        }
        print(selectStmt)
        let _ = selectStatement.prepare(statement: selectStmt)
        if let thisId = id, thisId > 0 { selectStatement.bindParam(thisId) }
        let _ = selectStatement.execute()
        let results = selectStatement.results()
        var res: [[Any?]] = []
        let _ = results.forEachRow { row in
            res.append(row)
        }
        return res
    }
    
    private func getFromMySQL(id: UInt64? = nil) throws -> String {
        var json: String = "["
        let rows = self.select(id: id)
        if rows.isEmpty {
            throw CSCustomDataError.mysqlFetchError
        }
        if  rows[0].count != self.properties.count + 1 {
            throw CSCustomDataError.mysqlFetchError
        }
        let temp: [CSDynamicEntityPropertyDescription] = [CSDynamicEntityPropertyDescription(name: "temp", label: "temp")]
        var n = 0
        for row in rows {
            if n != 0 {
                json += ","
            }
            n += 1
            json += "{"
            for i in 0..<self.properties.count+1 {
                let anyValue = row[i]
                let field = (temp + self.properties)[i]
                if i != 0 {
                    json += ","
                    switch field.jsType {
                    case .string, .datetime :
                        guard let str = anyValue as? String else {
                            throw CSCustomDataError.notValidJSONValue(key: "\(field.name):\(String(describing: anyValue))")
                        }
                        json += "\"\(field.name)\":\"\(str)\""
                    case .number :
                        guard let number = anyValue as? Int else {
                            throw CSCustomDataError.notValidJSONValue(key: "\(field.name):\(String(describing: anyValue))")
                        }
                        json += "\"\(field.name)\":\(number)"
                    case .numbersArray, .object, .objectsArray :
                        guard let str = anyValue as? String else {
                            throw CSCustomDataError.notValidJSONValue(key: "\(field.name):\(String(describing: anyValue))")
                        }
                        json += "\"\(field.name)\":\(str)"
                    case .bool :
                        guard let bool = anyValue as? Int8 else {
                            throw CSCustomDataError.notValidJSONValue(key: "\(field.name):\(String(describing: anyValue))")
                        }
                        if bool == 1 {
                            json += "\"\(field.name)\":true"
                        }else{
                            json += "\"\(field.name)\":false"
                        }
                    case .float :
                        guard let number = anyValue as? Double else {
                            throw CSCustomDataError.notValidJSONValue(key: "\(field.name):\(String(describing: anyValue))")
                        }
                        json += "\"\(field.name)\":\(number)"
                    }
                }else{
                    guard let id = row[0] as? UInt64 else {
                        throw CSCustomDataError.notValidJSONValue(key: "\(field.name):\(String(describing: anyValue))")
                    }
                    json += "\"id\":\(id)"
                }
            }
            json += "}"
        }
        json += "]"
        return json
    }
    private static func exec(_ statement: String, params: [Any], mysql: MySQL) throws {
        let lastStatement = MySQLStmt(mysql)
        let _ = lastStatement.prepare(statement: statement)
        for p in params {
            lastStatement.bindParam("\(p)")
        }
        if !lastStatement.execute() {
            throw CSCoreDBError.databaseError
        }
        let _ = lastStatement.results()
    }
    
    
    private func saveData(json: String) throws -> String {
        var id: UInt64 = 0
        var values: [String: Any] = try self.decode(jsonString: json)
        if let thisId = values["id"] as? UInt64 {
            id = thisId
        }
        var rels: [(String,UInt64)] = []
        let newStatement = MySQLStmt(self.mysql)
        var stmt: String = ""
        var params: [Any] = []
        var i = 0
        let _ = try? CSCustomData.exec("BEGIN;", params: [], mysql: self.mysql)
        let refFields = self.properties.filter({ p in p.refRegisterName != nil && p.fieldType == .multipleSelect})
        if id > 0 {
            stmt = "UPDATE \(registerName) SET "
            for (k, v) in values {
                let f = refFields.filter({ p in p.name == k})
                if  f.count == 1 {
                    let deleteOldStmt: String = "DELETE FROM \(self.registerName)_\(f[0].refRegisterName!) WHERE \(self.registerName)_id = ?;"
                    let deleteStament = MySQLStmt(self.mysql)
                    if !deleteStament.prepare(statement: deleteOldStmt) {
                        let _ = self.mysql.rollback()
                        throw CSCustomDataError.mysqlSaveError(error: .prepare, message: deleteStament.errorMessage())
                    }
                    deleteStament.bindParam("\(id)")
                    if !deleteStament.execute() {
                        let _ = self.mysql.rollback()
                        throw CSCustomDataError.mysqlSaveError(error: .execute, message: deleteStament.errorMessage())
                    }
                    guard let jsonArray = v as? String else {
                        throw CSCustomDataError.notValidJSONValue(key: k)
                    }
                    guard let decodedRels = try? JSONDecoder().decode([UInt64].self, from: jsonArray.data(using: .utf8)!) else {
                        throw CSCustomDataError.notValidJSONValue(key: k)
                    }
                    for rel in decodedRels {
                        let insertStmt = "INSERT INTO \(self.registerName)_\(f[0].refRegisterName!) (\(self.registerName)_id, \(f[0].refRegisterName!)_id) VALUES (?, ?);"
                        let insertStatement = MySQLStmt(self.mysql)
                        if !insertStatement.prepare(statement: insertStmt) {
                            let _ = self.mysql.rollback()
                            throw CSCustomDataError.mysqlSaveError(error: .prepare, message: insertStatement.errorMessage())
                        }
                        insertStatement.bindParam("\(id)")
                        insertStatement.bindParam("\(rel)")
                        if !insertStatement.execute() {
                            let _ = self.mysql.rollback()
                            throw CSCustomDataError.mysqlSaveError(error: .execute, message: insertStatement.errorMessage())
                        }
                    }
                }else{
                    if i != 0 {
                        stmt += ", "
                    }
                    i += 1
                    stmt += "\(k) = ?"
                    params.append(v)
                }
            }
            stmt += " WHERE `id` = ?;"
            guard let id = values["id"] as? UInt64 else {
                throw CSCustomDataError.notValidJSONValue(key: "id")
            }
            params.append(id)
        }else{
            stmt = "INSERT INTO \(registerName) ("
            var vals: String = "VALUES ("
            for (k, v) in values {
                let f = refFields.filter({ p in p.name == k})
                if  f.count == 1 {
                    guard let jsonArray = v as? String else {
                        throw CSCustomDataError.notValidJSONValue(key: k)
                    }
                    guard let decodedRels = try? JSONDecoder().decode([UInt64].self, from: jsonArray.data(using: .utf8)!) else {
                        throw CSCustomDataError.notValidJSONValue(key: k)
                    }
                    for r in decodedRels {
                        rels.append((f[0].refRegisterName!, r))
                    }
                }else{
                    if i != 0 {
                        stmt += ", "
                        vals += ", "
                    }
                    i += 1
                    stmt += "`\(k)`"
                    vals += "?"
                    params.append(v)
                }
            }
            stmt += ") \(vals));"
        }

        if !newStatement.prepare(statement: stmt) {
            let _ = self.mysql.rollback()
            throw CSCustomDataError.mysqlSaveError(error: .prepare, message: newStatement.errorMessage())
        }
        
        for param in params {
            newStatement.bindParam("\(param)")
        }
        if !newStatement.execute() {
            let _ = self.mysql.rollback()
            throw CSCustomDataError.mysqlSaveError(error: .execute, message: newStatement.errorMessage())
        }
        let _ = newStatement.results()
        if newStatement.affectedRows() > 0 {
            id = id > 0 ? id : UInt64(newStatement.insertId())
            for (ref, rel) in rels {
                let insertStmt = "INSERT INTO \(self.registerName)_\(ref) (\(self.registerName)_id, \(ref)_id) VALUES (?, ?);"
                let insertStatement = MySQLStmt(self.mysql)
                if !insertStatement.prepare(statement: insertStmt) {
                    let _ = self.mysql.rollback()
                    throw CSCustomDataError.mysqlSaveError(error: .prepare, message: insertStatement.errorMessage())
                }
                insertStatement.bindParam("\(id)")
                insertStatement.bindParam("\(rel)")
                if !insertStatement.execute() {
                    let _ = self.mysql.rollback()
                    throw CSCustomDataError.mysqlSaveError(error: .execute, message: insertStatement.errorMessage())
                }
            }
            let _ = self.mysql.commit()
            
        }else{
            let _ = self.mysql.rollback()
        }
        return try self.getFromMySQL(id: id)
    }
    
    public enum CSCustomDataError: Error {
        case notValidJSON
        case notValidJSONValue(key: String)
        case initError
        case mysqlFetchError
        case mysqlSaveError(error: MysqlStatementError, message: String)
        case mysqlCreateError(error: MysqlStatementError, message: String)
        case createError
    }
    public enum MysqlStatementError: Error {
        case prepare
        case execute
        case result
    }
}
