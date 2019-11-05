//
//  CSOptianableProtocol.swift
//  CSCoreDB
//
//  Created by Georgie Ivanov on 19.08.19.
//

public protocol CSOptionableProtocol {
    static var registerName: String { get }
    static func options() -> [UInt64:String]
    static var isButton: Bool { get }
}

public protocol CSOptionableEnumProtocol: CSOptionableProtocol, CaseIterable {
    func getName() -> String?
}

public extension CSViewDatabaseProtocol where Entity: RawRepresentable, Entity: CSOptionableEnumProtocol, Entity.RawValue == Int {
    static func options() -> [UInt64:String] {
        var res: [UInt64:String] = [:]
        if let allCases = Entity.allCases as? [Entity] {
            for option in allCases {
                guard let name = option.getName() else {
                    continue
                }
                res[UInt64(option.rawValue)] = name
            }
        }
        return res
    }
    static var isButton: Bool {
        false
    }
}
public protocol CSOptionableEntityProtocol {
    static var optionField: AnyKeyPath { get }
}
public extension CSViewDatabaseProtocol where Entity: CSOptionableEntityProtocol {
    static func options() -> [UInt64:String] {
        var res: [UInt64: String] = [:]
        do {
            if let queryResult = try Entity.view().db?.table(Entity.self).select().map({ ($0.id, $0[keyPath: Entity.optionField]) }) {
                for (k,v) in queryResult {
                    if let s = v as? String {
                        res[k] = s
                    }
                }
            }
        } catch {
            print(error)
        }
        return res
    }
    static var isButton: Bool {
        true
    }
}
