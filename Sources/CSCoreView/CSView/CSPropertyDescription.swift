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
    order: Int,
    label: String
    
    public init(
        keyPath: AnyKeyPath,
        name: String,
        label: String,
        ref: CSOptionableProtocol.Type? = nil,
        fieldType: FieldType = .text,
        jsType: JSType = .string,
        colWidth: ColWidth = .normal,
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
        self.label = label
    }
    // Codable keys
    enum CodingKeys: String, CodingKey {
        case fieldType, jsType, colWidth, name, required, label, order
    }
    // Encodable conformance
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(fieldType, forKey: .fieldType)
        try container.encode(jsType, forKey: .jsType)
        try container.encode(colWidth, forKey: .colWidth)
        try container.encode(required, forKey: .required)
        try container.encode(label, forKey: .label)
        try container.encode(order, forKey: .order)
    }
//    public init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
//        label = try values.decodeIfPresent(String.self, forKey: .label) ?? ""
//        fieldType = try values.decodeIfPresent(FieldType.self, forKey: .fieldType) ?? .text
//        jsType = try values.decodeIfPresent(JSType.self, forKey: .jsType) ?? .string
//        colWidth = try values.decodeIfPresent(ColWidth.self, forKey: .colWidth) ?? .normal
//        required = try values.decodeIfPresent(Bool.self, forKey: .required) ?? true
//        order = try values.decodeIfPresent(Int.self, forKey: .order) ?? 0
//    }
}

public enum FieldType: String, Codable, CaseIterable {
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

public enum ColWidth: Int, Codable, CaseIterable {
    case small = 50
    case normal = 150
    case medium = 200
    case large = 250
    case larger = 300
    case largest = 400
    case extraLarge = 500
}

public enum JSType: String, Codable, CaseIterable {
    case number, float, string, bool, datetime, objectsArray, numbersArray, object
}
