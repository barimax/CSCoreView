//
//  CSSearchableProtocol.swift
//  CSCoreDB
//
//  Created by Georgie Ivanov on 14.09.19.
//

import PerfectCRUD

public extension CSEntityProtocol {
    static func search(query: String) -> [CSBaseEntityProtocol] {
        var res: [CSBaseEntityProtocol]  = []
        do {
            if Self.searchableFields.count > 0 {
                if let searchKeyPath = Self.searchableFields[0] as? KeyPath<Entity, String> {
                    var expression = searchKeyPath %=% query
                    for index in 1..<Self.searchableFields.count {
                        if let sKeyPath = Self.searchableFields[index] as? KeyPath<Entity, String> {
                            expression = expression || sKeyPath %=% query
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
