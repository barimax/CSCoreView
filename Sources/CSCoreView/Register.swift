//
//  Register.swift
//  CSCoreDB
//
//  Created by Georgie Ivanov on 18.08.19.
//

import Foundation

public class Register {
    public static var registerStore: [String: Any] = [:]
    private var locked: Bool = false
    
    public func add(entityType: Any.Type, forKey: String) throws {
        if Register.registerStore[forKey] == nil && !locked {
            Register.registerStore[forKey] = entityType
        }else{
            throw CSViewError.registerError(message: "Type for this key already exists.")
        }
    }
    public func get(forKey: String) throws -> Any.Type {
        guard let type = Register.registerStore[forKey], let result = type as? Any.Type else {
            throw CSViewError.registerError(message: "No type found for this key.")
        }
        return result
    }
    public func getAll() -> [Any.Type] {
        var result: [Any.Type] = []
        for (_, value) in Register.registerStore {
            if let r: Any.Type = value as? Any.Type {
                result.append(r)
            }
        }
        return result
    }
    func lock() {
        self.locked = true
    }
}
