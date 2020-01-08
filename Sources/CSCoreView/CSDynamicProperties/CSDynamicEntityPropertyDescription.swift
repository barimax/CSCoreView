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
    public let refRegisterName: String?
    
    public init(
        name: String,
        refRegisterName: String? = nil,
        fieldType: FieldType = FieldType.text,
        jsType: JSType = .string,
        colWidth: ColWidth = .normal,
        required: Bool = true,
        order: Int = 0,
        label: String
    ) {
        self.name = name
        self.label = label
        self.refRegisterName = refRegisterName
        self.fieldType = fieldType
        self.jsType = jsType
        self.colWidth = colWidth
        self.required = required
        self.order = order
    }
}
