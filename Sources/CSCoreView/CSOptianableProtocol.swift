//
//  CSOptianableProtocol.swift
//  CSCoreDB
//
//  Created by Georgie Ivanov on 19.08.19.
//
import CSCoreDB

public protocol CSOptionableProtocol: CSDatabaseProtocol {
    static var optionField: AnyKeyPath { get }
    func options() -> [Int:String]
}
extension CSOptionableProtocol {
    func options() -> [Int:String] {
        var res: [Int: String] = [:]
        do {
            let queryResult = try table.select().map { ($0.id, $0[keyPath: Self.optionField]) }
            for (k,v) in queryResult {
                if let s = v as? String {
                    res[k] = s
                }
            }
        } catch {
            print(error)
        }
        return res
    }
}
public protocol CSOptionableDelegate {
    static var optionField: AnyKeyPath { get }
    func options() -> [Int:String]
    static var registerName: String { get }
}
