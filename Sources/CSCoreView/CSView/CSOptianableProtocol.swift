//
//  CSOptianableProtocol.swift
//  CSCoreDB
//
//  Created by Georgie Ivanov on 19.08.19.
//

public protocol CSOptionableProtocol {
    static var registerName: String { get }
    static func options() -> [UInt64:String]
}

public protocol CSOptionableEnumProtocol: CSOptionableProtocol, CaseIterable {
    func getName() -> String?
}

public extension CSOptionableEnumProtocol where Self: RawRepresentable, Self.RawValue == Int {
    static func options() -> [UInt64:String] {
        var res: [UInt64:String] = [:]
        if let allCases = Self.allCases as? [Self] {
            for option in allCases {
                guard let name = option.getName() else {
                    continue
                }
                res[UInt64(option.rawValue)] = name
            }
        }
        return res
    }
}
public protocol CSOptionableFieldProtocol: CSOptionableProtocol {
    static var optionField: AnyKeyPath { get }
}

public protocol CSOptionableEntityProtocol: CSOptionableFieldProtocol {
    associatedtype Entity: CSEntityProtocol
}
public extension CSOptionableEntityProtocol {
    static func options() -> [UInt64:String] {
        var res: [UInt64: String] = [:]
        do {
            if let queryResult = try Entity.view().db?.table(Entity.self).select().map({ ($0.id, $0[keyPath: Self.optionField]) }) {
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
}
