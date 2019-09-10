//
//  CSOptianableProtocol.swift
//  CSCoreDB
//
//  Created by Georgie Ivanov on 19.08.19.
//
import CSCoreDB

public protocol CSOptionableProtocol {
    static var optionField: AnyKeyPath { get }
    static var registerName: String { get }
    static func options() -> [Int:String]
}

public protocol CSOptionableEntityProtocol: CSOptionableProtocol {
    associatedtype Entity: CSEntityProtocol
    static func view() throws -> CSView<Entity>
}
public extension CSOptionableEntityProtocol {
    static func options() -> [Int:String] {
        var res: [Int: String] = [:]
        if let view = try? self.view() {
            do {
                let queryResult = try view.table.select().map { ($0.id, $0[keyPath: Self.optionField]) }
                for (k,v) in queryResult {
                    if let s = v as? String {
                        res[k] = s
                    }
                }
            } catch {
                print(error)
            }
        }
        return res
    }
}
