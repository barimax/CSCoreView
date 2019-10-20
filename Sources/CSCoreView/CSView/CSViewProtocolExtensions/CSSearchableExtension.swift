//
//  CSSearchableProtocol.swift
//  CSCoreDB
//
//  Created by Georgie Ivanov on 14.09.19.
//

import PerfectCRUD

public extension CSViewDatabaseProtocol {
    func search(query: String) -> [CSEntityProtocol] {
        var res: [Entity]  = []
        do {
            if self.searchableFields.count > 0 {
                if let searchKeyPath = self.searchableFields[0] as? KeyPath<Entity, String> {
                    var expression = searchKeyPath %=% query
                    for index in 1..<self.searchableFields.count {
                        if let sKeyPath = self.searchableFields[index] as? KeyPath<Entity, String> {
                            expression = expression || sKeyPath %=% query
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
