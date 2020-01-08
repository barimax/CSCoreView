//
//  CSDynamicEntity.swift
//  CSCoreView
//
//  Created by Georgie Ivanov on 2.01.20.
//

struct CSDynamicEntity: CSEntityProtocol {
    static var registerName: String = "dynamicEntity"
    static var tableName: String = "customTypes"
    static var singleName: String = "Custom type"
    static var pluralName: String = "Custom types"
    static var searchableFields: [AnyKeyPath] = [\CSDynamicEntity.name]
    static var fields: [CSPropertyDescription] = [
        CSPropertyDescription(
            keyPath: \CSDynamicEntity.name,
            name: "name",
            label: "Name",
            ref: nil,
            fieldType: .text,
            jsType: .string,
            colWidth: .normal,
            required: true,
            order: 0)
    ]
    
    
    var id: UInt64
    var name: String
    var properties: [String: CSDynamicEntityPropertyDescription]
}
