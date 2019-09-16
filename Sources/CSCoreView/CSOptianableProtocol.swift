//
//  CSOptianableProtocol.swift
//  CSCoreDB
//
//  Created by Georgie Ivanov on 19.08.19.
//

public protocol CSOptionableProtocol {
    static var optionField: AnyKeyPath { get }
    static var registerName: String { get }
    static func options() -> [UInt64:String]
    static func view() throws -> CSView
}

public protocol CSOptionableEntityProtocol: CSOptionableProtocol {
    associatedtype Entity: CSEntityProtocol
}
public extension CSOptionableEntityProtocol {
    static func options() -> [UInt64:String] {
        var res: [UInt64: String] = [:]
        do {
            if let queryResult = try Entity.table?.select().map({ ($0.id, $0[keyPath: Self.optionField]) }) {
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
