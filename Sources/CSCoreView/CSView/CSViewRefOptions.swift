//
//  CSViewRefOptions.swift
//  CSCoreDB
//
//  Created by Georgie Ivanov on 23.08.19.
//

import Foundation

public struct CSRefOptionField: Codable {
    public let registerName: String
    public let options: [CSOption]
    public var isButton: Bool
    public init(registerName: String, options: [CSOption], isButton: Bool) {
        self.registerName = registerName
        self.options = options
        self.isButton = isButton
    }
}
public struct CSBackRefs: Codable {
    var registerName: String = ""
    var formField: String = ""
    var names: [String:String] = [:] //???
    var singleName: String = ""
    var pluralName: String = ""
    var createNewByMultiple: Bool = false
    var createNewByMultipleFields: [String] = []
    public init() {}
}
public struct CSOption: Codable {
    var value: UInt64
    var text: String
    var addOn: String?
    public init(value v: UInt64, text t: String){
        self.value = v
        self.text = t
    }
}

public struct CSRefView: Codable {
    public let fields: [CSDynamicEntityPropertyDescription]
    public let refOptions: [String:CSRefOptionField]
    public var defaultValue: [CSDynamicFieldEntityProtocol] = []
    
    public init(fields f: [CSDynamicEntityPropertyDescription], refOptions r: [String:CSRefOptionField], defaultValue d: [CSDynamicFieldEntityProtocol] ) {
        self.fields = f
        self.refOptions = r
        self.defaultValue = d
    }
    
    // Codable keys
    enum CodingKeys: String, CodingKey {
        case fields, refOptions, defaultValue
    }
    // Encodable conformance
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fields, forKey: .fields)
        try container.encode(refOptions, forKey: .refOptions)
        try container.encode(self.defaultValue.map { EncodableWrapper($0) }, forKey: .defaultValue)
    }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        fields = try values.decodeIfPresent([CSDynamicEntityPropertyDescription].self, forKey: .fields) ?? []
        refOptions = try values.decodeIfPresent([String:CSRefOptionField].self, forKey: .refOptions) ?? [:]
        defaultValue = try DecodableWrapper(from: decoder).base as? [CSDynamicFieldEntityProtocol] ?? []
    }
}
