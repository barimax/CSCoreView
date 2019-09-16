//
//  CSFindableProtocol.swift
//  CSCoreDB
//
//  Created by Georgie Ivanov on 14.09.19.
//

import Foundation

public protocol CSFindableProtocol {
    static var fields: [CSPropertyDescription] { get }
    static func find(criteria: [String: Any]) -> [CSBaseEntityProtocol]
}

public protocol CSFindableEntityProtocol: CSFindableProtocol {
    associatedtype Entity: CSEntityProtocol
}
public extension CSFindableEntityProtocol {
    public static func find(criteria: [String: Any]) -> [CSBaseEntityProtocol] {
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
                        if let keyPath = anyKeyPath as? KeyPath<Entity, String>, fKeyPath != keyPath {
                            expression = Entity.andExpression(l: expression, r: Entity.equalExpression(keyPath: keyPath, query: "\(value)"))
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
