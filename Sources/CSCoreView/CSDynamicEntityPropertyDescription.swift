//
//  CSDynamicEntityPropertyDescription.swift
//  CSCoreView
//
//  Created by Georgie Ivanov on 2.01.20.
//

struct CSDynamicEntityPropertyDescription: Codable {
    let name: String,
    fieldType: FieldType,
    jsType: JSType,
    colWidth: ColWidth,
    required: Bool,
    order: Int,
    label: String,
    refRegisterName: String?
}
