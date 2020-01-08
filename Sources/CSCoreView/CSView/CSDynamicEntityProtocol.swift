//
//  CSDynamicEntity.swift
//  CSCoreView
//
//  Created by Georgie Ivanov on 2.01.20.
//

public protocol CSDynamicFieldProtocol: Codable {
    static var fields: [CSDynamicEntityPropertyDescription] { get }
}
