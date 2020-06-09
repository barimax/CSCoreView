//
//  CSDynamicEntityPropertyDescription.swift
//  CSCoreView
//
//  Created by Georgie Ivanov on 2.01.20.
//

public struct CSDynamicEntityPropertyDescription: Codable {
    public let name: String
    public let fieldType: FieldType
    public let jsType: JSType
    public let colWidth: ColWidth
    public let required: Bool
    public let order: Int
    public let label: String
    public let ref: CSOptionableProtocol.Type?
    public let disabled: Bool
    
    public init(
        name: String,
        ref: CSOptionableProtocol.Type? = nil,
        fieldType: FieldType = FieldType.text,
        jsType: JSType = .string,
        colWidth: ColWidth = .normal,
        required: Bool = true,
        order: Int = 0,
        label: String,
        disabled: Bool = false
    ) {
        self.name = name
        self.label = label
        self.ref = ref
        self.fieldType = fieldType
        self.jsType = jsType
        self.colWidth = colWidth
        self.required = required
        self.order = order
        self.disabled = disabled
    }
    // Codable keys
    enum CodingKeys: String, CodingKey {
        case fieldType, jsType, colWidth, name, required, label, order, disabled, ref
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
        try container.encode(disabled, forKey: .disabled)
        try container.encode(ref?.registerName, forKey: .ref)
    }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        label = try values.decodeIfPresent(String.self, forKey: .label) ?? ""
        fieldType = try values.decodeIfPresent(FieldType.self, forKey: .fieldType) ?? .text
        jsType = try values.decodeIfPresent(JSType.self, forKey: .jsType) ?? .string
        colWidth = try values.decodeIfPresent(ColWidth.self, forKey: .colWidth) ?? .normal
        required = try values.decodeIfPresent(Bool.self, forKey: .required) ?? true
        order = try values.decodeIfPresent(Int.self, forKey: .order) ?? 0
        guard let refRegisterName = try values.decodeIfPresent(String.self, forKey: .ref),
            let refType = try CSRegister.getType(forKey: refRegisterName) as? CSOptionableProtocol.Type else {
                throw CSViewError.dynamicFieldError
        }
        ref = refType
        disabled = try values.decodeIfPresent(Bool.self, forKey: .disabled) ?? false
    }
}
