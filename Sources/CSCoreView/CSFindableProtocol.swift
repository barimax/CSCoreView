//
//  CSFindableProtocol.swift
//  CSCoreDB
//
//  Created by Georgie Ivanov on 14.09.19.
//

import PerfectCRUD

public protocol CSFindableProtocol {
    static var fields: [CSPropertyDescription] { get }
    static func find(criteria: [String: Any]) -> [CSBaseEntityProtocol]
    var id: UInt64 { get }
}

public protocol CSFindableEntityProtocol: CSFindableProtocol {
    associatedtype Entity: CSEntityProtocol
}
public extension CSFindableEntityProtocol {
    private static func createExpression(_ anyKeyPath: AnyKeyPath, value: Any) -> CRUDBooleanExpression? {
        switch (anyKeyPath, value) {
        case let (fk, fv) as (KeyPath<Entity, String>, String):
            return fk == fv
        case let (fk, fv) as (KeyPath<Entity, UInt64>, UInt64):
            return fk == fv
        case let (fk, fv) as (KeyPath<Entity, Int>, Int):
            return fk == fv
        case let (fk, fv) as (KeyPath<Entity, Int8>, Int8):
            return fk == fv
        case let (fk, fv) as (KeyPath<Entity, Bool>, Bool):
            return fk == fv
        default :
            return nil
        }
    }
    public static func find(criteria: [String: Any]) -> [CSBaseEntityProtocol] {
        var res: [CSBaseEntityProtocol] = []
        do {
            var keyPathsValues: [AnyKeyPath: Any] = [:]
            for (key, value) in criteria {
                if key == "id" || key == "ID" || key == "iD" || key == "Id" {
                    if let v = value as? Int {
                        keyPathsValues[\Entity.id] = UInt64(v)
                    }
                }
                for field in Self.fields {
                    if field.name == key {
                        keyPathsValues[field.keyPath] = value
                    }
                }
            }
            if keyPathsValues.count > 0 {
                let first = keyPathsValues.remove(at: keyPathsValues.startIndex)
                if var expression = Self.createExpression(first.key, value: first.value) {
                    for (anyKeyPath, value) in keyPathsValues {
                        if let curExpr = Self.createExpression(anyKeyPath, value: value) {
                            expression = expression && curExpr
                        }
                    }
                    if let result = try Entity.table?.where(expression).select().map({ $0 }) {
                        res = result
                    }
                }
            }
        } catch {
            print(error)
        }
        return res
    }
}
