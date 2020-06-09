//
//  CSFindableProtocol.swift
//  CSCoreDB
//
//  Created by Georgie Ivanov on 14.09.19.
//

import PerfectCRUD

extension CSViewDatabaseProtocol {
    private func createExpression(_ anyKeyPath: AnyKeyPath, value: String) -> CRUDBooleanExpression? {
        switch (anyKeyPath) {
        case let fk as KeyPath<Entity, String>:
            return fk == value
        case let fk as KeyPath<Entity, UInt64>:
            guard let fv = UInt64(value) else {
                return nil
            }
            return fk == fv
        case let fk as KeyPath<Entity, Int>:
            guard let fv = Int(value) else {
                return nil
            }
            return fk == fv
        case let fk as KeyPath<Entity, Int8>:
            guard let fv = Int8(value) else {
                return nil
            }
            return fk == fv
        case let fk as KeyPath<Entity, Bool>:
            if value == "true" {
                return fk == true
            }
            if value == "false" {
                return fk == false
            }
            return nil
        default :
            return nil
        }
    }
    func  find(criteria: [String: String]) -> [CSEntityProtocol] {
        var res: [Entity] = []
        do {
            var keyPathsValues: [AnyKeyPath: String] = [:]
            for (key, value) in criteria {
                if key == "id" || key == "ID" || key == "iD" || key == "Id" {
                    keyPathsValues[\Entity.id] = value
                }
                for field in self.fields {
                    if field.name == key {
                        keyPathsValues[field.keyPath] = value
                    }
                }
            }
            if keyPathsValues.count > 0 {
                let first = keyPathsValues.remove(at: keyPathsValues.startIndex)
                print("JORO: \(first)")
                if var expression = self.createExpression(first.key, value: first.value) {
                    print(expression)
                    for (anyKeyPath, value) in keyPathsValues {
                        if let curExpr = self.createExpression(anyKeyPath, value: value) {
                            expression = expression && curExpr
                        }
                    }
                    if let result = try self.table?.where(expression).select().map({ $0 }) {
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

