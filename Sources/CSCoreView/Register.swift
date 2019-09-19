//
//  Register.swift
//  CSCoreDB
//
//  Created by Georgie Ivanov on 18.08.19.
//

import Foundation

public class Register {
    public static var registerStore: [String: Any] = [:]
    public static func setup() throws {
        for (_, rs) in Register.registerStore {
            if let entity = rs as? CSBaseEntityProtocol.Type {
                print(entity)
                print(entity.registerName)
                try entity.create()
                if let mtm = entity as? CSManyToManyProtocol.Type {
                    
                    try mtm.createRefTypes()
                }
            }
        }
    }
}
