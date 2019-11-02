//
//  CSPropertyDescription.swift
//  CSCoreDB
//
//  Created by Georgie Ivanov on 18.08.19.
//

import Foundation

public struct CSPropertyDescription: Encodable {
    public let fieldType: FieldType,
    jsType: JSType,
    keyPath: AnyKeyPath,
    colWidth: ColWidth,
    name: String,
    required: Bool,
    ref: CSOptionableProtocol.Type?,
    order: Int
    
    public init(
        keyPath: AnyKeyPath,
        ref: CSOptionableProtocol.Type? = nil,
        fieldType: FieldType = .text,
        jsType: JSType = .string,
        colWidth: ColWidth = .normal,
        name: String = "name",
        required: Bool = true,
        order: Int = 0
        ){
        
        self.keyPath = keyPath
        self.fieldType = fieldType
        self.jsType = jsType
        self.colWidth = colWidth
        self.name = name
        self.required = required
        self.ref = ref
        self.order = order
    }
    // Codable keys
    enum CodingKeys: String, CodingKey {
        case fieldType, jsType, colWidth, name, required
    }
    // Encodable conformance
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(fieldType, forKey: .fieldType)
        try container.encode(jsType, forKey: .jsType)
        try container.encode(colWidth, forKey: .colWidth)
        try container.encode(required, forKey: .required)
    }
}

public enum FieldType: String, Codable {
    case text,
    hidden,
    select,
    multipleSelect,
    selectedDisable,
    dateTime,
    textarea,
    textDisabled,
    dbSelect,
    dynamicFormControl,
    info,
    checkbox,
    date,
    time,
    `switch`,
    password,
    email
}

public enum ColWidth: Int, Codable {
    case small = 50
    case normal = 150
    case medium = 200
    case large = 250
    case larger = 300
    case largest = 400
    case extraLarge = 500
}

public enum JSType: String, Codable {
    case number, float, string, bool, datetime, array, object
}
