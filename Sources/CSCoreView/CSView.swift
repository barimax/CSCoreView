//
//  CSView.swift
//  CSCoreDB
//
//  Created by Georgie Ivanov on 18.08.19.
//
import Foundation
import PerfectCRUD
import PerfectMySQL
import CSCoreDB

public class CSView: CSViewProtocol {
    public var registerName: String
    public var singleName: String
    public var pluralName: String
    public var fields: [CSPropertyDescription]
    
    public var entity: CSBaseEntityProtocol? //???
    public var rows: [CSBaseEntityProtocol]? //???
   
    init(entity e: CSBaseEntityProtocol.Type){
        registerName = e.registerName
        singleName = e.singleName
        pluralName = e.pluralName
        fields = e.fields
    }
    
    
    // Codable keys
    enum CodingKeys: String, CodingKey {
        case registerName, fields, refs, encodedRows, refOptions, entity, dynamicParentFieldName, singleName, pluralName, backRefs, isSP, spIdName, filteredRefOptions, isAllowedOptionsDelegate, isDocumentView, documentRecords, recordView, recordsFieldName, gen
    }
    // Encodable conformance
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(registerName, forKey: .registerName)
//        try container.encode(entity, forKey: .entity)
        try container.encode(singleName, forKey: .singleName)
        try container.encode(pluralName, forKey: .pluralName)
    }
    
    // Decodable conformance
    required public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.registerName = try values.decodeIfPresent(String.self,forKey: .registerName) ?? ""
        self.singleName = try values.decodeIfPresent(String.self,forKey: .singleName) ?? ""
        self.pluralName = try values.decodeIfPresent(String.self,forKey: .pluralName) ?? ""
        self.fields = []
//        self.refs = try values.decodeIfPresent([String:String].self,forKey: .refs) ?? [:]
//        self.encodedRows = try values.decodeIfPresent(String.self,forKey: .encodedRows) ?? ""
//        self.entity = try values.decodeIfPresent(String.self,forKey: .entity)
//        self.dynamicParentFieldName = try values.decodeIfPresent(String.self,forKey: .dynamicParentFieldName)
//        self.isSP = try values.decodeIfPresent(Bool.self,forKey: .isSP) ?? false
//        self.spIdName = try values.decodeIfPresent(String.self,forKey: .spIdName)
        
    }
}

