//
//  CSFindableProtocol.swift
//  CSCoreDB
//
//  Created by Georgie Ivanov on 14.09.19.
//

import Foundation

protocol CSFindableProtocol {
    static var fields: [CSPropertyDescription] { get }
    static func find(criteria: [String: Any]) -> [CSBaseEntityProtocol]
}

protocol CSFindableEntityProtocol: CSFindableProtocol {
    associatedtype Entity: CSEntityProtocol
}
extension CSFindableEntityProtocol {
    static func find(criteria: [String: Any]) -> [CSBaseEntityProtocol] {
        var res: [CSBaseEntityProtocol] = []
        do {
            var keyPathsValues: [AnyKeyPath: Any] = [:]
            for (key, value) in criteria {
                for field in Self.fields {
                    if field.name == key {
                        keyPathsValues[field.keyPath] = value
                    }
                }
            }
            if keyPathsValues.count > 0 {
                if let firstKeyPath = keyPathsValues.first?.key, let firstValue = keyPathsValues.first?.value, let fKeyPath = firstKeyPath as? KeyPath<Entity, String> {
                    var expression = Entity.equalExpression(keyPath: fKeyPath, query: "\(firstValue)")
                    for (anyKeyPath, value) in keyPathsValues {
                        if let keyPath = anyKeyPath as? KeyPath<Entity, String> {
                            expression = Entity.andExpression(l: expression, r: Entity.likeExpression(keyPath: keyPath, query: "\(value)"))
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
