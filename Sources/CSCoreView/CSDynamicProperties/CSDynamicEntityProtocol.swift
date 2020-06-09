//
//  CSDynamicEntity.swift
//  CSCoreView
//
//  Created by Georgie Ivanov on 2.01.20.
//

public protocol CSDynamicFieldProtocol: Codable, CSOptionableProtocol {
    static var fields: [CSDynamicEntityPropertyDescription] { get }
    static var defaultValue: [CSDynamicFieldEntityProtocol]? { get }
    var value: [CSDynamicFieldEntityProtocol] { get }
}
public protocol CSDynamicFieldEntityProtocol: Codable {}
public extension CSDynamicFieldProtocol {
    static func options(_ db: String) -> [CSOption] { return [] }
}
