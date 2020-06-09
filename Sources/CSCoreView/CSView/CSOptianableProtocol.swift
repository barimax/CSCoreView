//
//  CSOptianableProtocol.swift
//  CSCoreDB
//
//  Created by Georgie Ivanov on 19.08.19.
//

public protocol CSOptionableProtocol  {
    static var isButton: Bool { get }
    static func options(_ db: String) -> [CSOption]
    static var registerName: String { get }
}
public protocol CSOptionableEntityProtocol: CSOptionableProtocol  {
    static var optionField: AnyKeyPath { get }
}
public extension CSOptionableEntityProtocol where Self: CSEntityProtocol  {
    static func options(_ db: String) -> [CSOption] {
        var res: [CSOption] = []
        do {
            if let queryResult = try Self.view(db).db?.table(Self.self).select().map({ ($0.id, $0[keyPath: Self.optionField]) }) {
                
                for (k,v) in queryResult {
                    if let s = v as? String {
                        res.append(CSOption(value: k, text: s))
                    }
                }
            }
        } catch {
            print(error)
        }
        return res
    }
    static var isButton: Bool {
        return true
    }
}
public protocol CSOptionableEnumProtocol: CSOptionableProtocol, CaseIterable {
    func getName() -> String?
}
public extension CSOptionableEnumProtocol {
    static var isButton: Bool {
        return false
    }
}

public extension CSOptionableEnumProtocol where Self: RawRepresentable, Self.RawValue == Int {
    static func options(_ db: String) -> [CSOption] {
        var res: [CSOption] = []
        if let allCases = Self.allCases as? [Self] {
            for option in allCases {
                guard let name = option.getName() else {
                    continue
                }
                res.append(CSOption(value: UInt64(option.rawValue), text: name))
            }
        }
        return res
    }
}

