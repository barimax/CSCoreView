//
//  CSDynamicEntity.swift
//  CSCoreView
//
//  Created by Georgie Ivanov on 2.01.20.
//

public protocol CSDynamicFieldProtocol: Codable, CSOptionableProtocol {
    static var fields: [CSDynamicEntityPropertyDescription] { get }
}
public extension CSDynamicFieldProtocol {
    static func options(_ db: String) -> [UInt64: String] { return [:] }
}
