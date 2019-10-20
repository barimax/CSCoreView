//
//  CSEntity.swift
//  CSCoreView
//
//  Created by Georgie Ivanov on 20.10.19.
//

import Foundation


extension Encodable {
  fileprivate func encode(to container: inout SingleValueEncodingContainer) throws {
    try container.encode(self)
  }
}

public class CSEntity {
    public var entity: CSEntityProtocol?
    public var rows: [CSEntityProtocol] = []
    public var view: CSViewProtocol
    
    public init(registerName rn: String) throws {
        self.view = try CSRegister.getView(forKey: rn)
    }
    public init(registerName rn: String, encodedEntity: String) throws {
        DecodableWrapper.baseType = try CSRegister.getType(forKey: rn)
        guard let e = try JSONDecoder().decode(DecodableWrapper.self, from: encodedEntity.data(using: .utf8)!).base as? CSEntityProtocol else {
            throw CSViewError.noEntity
        }
        self.entity = e
        self.view = try CSRegister.getView(forKey: rn)
    }
    public func jsonString() throws -> String {
        let wrappedEntity = EncodableWrapper(self.entity)
        let wrappedRows = self.rows.map { EncodableWrapper($0) }
        let wrappedView = EncodableWrapper(self.view)
        struct EncodeEntity: Encodable {
            let entity: EncodableWrapper
            let rows: [EncodableWrapper]
            let view: EncodableWrapper
        }
        let encodeEntity = EncodeEntity(entity: wrappedEntity, rows: wrappedRows, view: wrappedView)
        guard let str = try String(data: JSONEncoder().encode(encodeEntity), encoding: .utf8) else {
            throw CSViewError.jsonError
        }
        return str
    }
    
    public func getAll() throws -> [CSEntityProtocol] { try self.view.getAll() }
    public func get(id: UInt64) throws -> CSEntityProtocol { try self.view.get(id: id) }
    public func delete(id: UInt64) throws { try self.view.delete(id: id) }
    public func find(criteria: [String: Any]) -> [CSEntityProtocol] { self.view.find(criteria: criteria) }
    public func search(query: String) -> [CSEntityProtocol] { self.view.search(query: query) }
    public func delete() throws {
        guard let e = self.entity else {
            throw CSViewError.noEntity
        }
        try self.view.delete(id: e.id)
        
    }
    public func loadAll() throws {
        self.rows = try self.getAll()
    }
    public func load(id: UInt64) throws {
        self.entity = try self.get(id: id)
    }
    public func save(entity: CSEntityProtocol) throws -> CSEntityProtocol {
        if type(of: self.view) == type(of: type(of: entity).view()) {
            return try self.view.save(entity: entity)
        }else{
            throw CSViewError.differentType
        }
    }
    public func saveAndLoad(entity: CSEntityProtocol) throws {
        self.entity = try self.save(entity: entity)
    }
}
struct DecodableWrapper: Decodable {
    static var baseType: Decodable.Type!
    var base: Decodable

    init(from decoder: Decoder) throws {
        self.base = try DecodableWrapper.baseType.init(from: decoder)
    }
}
struct EncodableWrapper : Encodable {
    var value: Encodable?
    init(_ value: Encodable?) {
        self.value = value
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try value?.encode(to: &container)
    }
}
