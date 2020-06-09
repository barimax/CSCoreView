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

public class CSEntity: Encodable {
    public var entity: CSEntityProtocol?
    public var rows: [CSEntityProtocol] = []
    public var view: CSViewProtocol
    public var registerName: String
    
    // Conforms to Encodable
    enum CodingKeys: String, CodingKey {
        case entity, rows, view
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(EncodableWrapper(self.entity), forKey: .entity)
        try container.encode(self.rows.map { EncodableWrapper($0) }, forKey: .rows)
        try container.encode(EncodableWrapper(self.view), forKey: .view)
    }
    /// Initialize with properties
    public init(view v: CSViewProtocol, registerName rn: String) {
        self.view = v
        self.registerName = rn
    }
    /// Initialize with type
    public init(withType t: CSEntityProtocol.Type, withDatabase db: String) {
        self.registerName = t.registerName
        self.view = t.view(db)
    }
    /// Initialize with empty entity
    public init(registerName rn: String, database db: String) throws {
        self.registerName = rn
        self.view = try CSRegister.getView(forKey: rn, withDatabase: db)
    }
    /// Initializa with entity
    public init(registerName rn: String, encodedEntity: String, database db: String) throws {
        DecodableWrapper.baseType = try CSRegister.getType(forKey: rn)
        guard let e = try JSONDecoder().decode(DecodableWrapper.self, from: encodedEntity.data(using: .utf8)!).base as? CSEntityProtocol else {
            throw CSViewError.noEntity
        }
        self.registerName = rn
        self.entity = e
        self.view = try CSRegister.getView(forKey: rn, withDatabase: db)
    }
    /// Return JSON encoded CSEntity (entity, rows & view)
    public func jsonString() throws -> String {
        guard let str = try String(data: JSONEncoder().encode(self), encoding: .utf8) else {
            throw CSViewError.jsonError
        }
        return str
    }
    
    /// Get all entities * Return CSEntityProtocol array
    public func getAll() throws -> [CSEntityProtocol] { return try self.view.getAll() }
    /// Get single entity * Return single entity by given id
    public func get(id: UInt64) throws -> CSEntityProtocol { return try self.view.get(id: id) }
    /// Delete entity by id if it is not presented in some other entity
    public func delete(id: UInt64) throws -> [DeleteResponse] {
        let entityId: UInt64 = id
        var resp: [DeleteResponse] = []
        var allowDelete: Bool = true
        for backRef in self.view.backRefs {
            let refEntity = try CSEntity(registerName: backRef.registerName, database: self.view.database)
            let result = refEntity.find(criteria: [backRef.formField: "\(entityId)"])
            if !result.isEmpty {
                allowDelete = false
                refEntity.rows = result
                guard let optionable = refEntity.view as? CSOptionableEntityProtocol.Type else {
                    throw CSViewError.searchError
                }
                let optionFieldName: String? = refEntity.view.fields.first(where: { f in
                    f.keyPath == optionable.optionField
                }).map { $0.name }
                guard let optionFieldNameUnwraped = optionFieldName else {
                    throw CSViewError.searchError
                }
                let delResp = DeleteResponse(registerName: backRef.registerName, optionFieldName: optionFieldNameUnwraped, refEntity: refEntity)
                   resp.append(delResp)
                }
            
        }
        if allowDelete {
            try self.view.delete(id: id)
        }
        return resp
    }
    /// Find all entities matching the criteria object
    public func find(criteria: [String: String]) -> [CSEntityProtocol] { return self.view.find(criteria: criteria) }
    /// Search all entites if given string is presented in some of searchable properties
    public func search(query: String) -> [CSEntityProtocol] { return self.view.search(query: query) }
    /// Delete current loaded entity
    public func delete() throws {
        guard let e = self.entity else {
            throw CSViewError.noEntity
        }
        try self.view.delete(id: e.id)
        
    }
    /// Load all entites
    public func loadAll() throws {
        self.rows = try self.getAll()
    }
    /// Load enitity by id
    public func load(id: UInt64) throws {
        self.entity = try self.get(id: id)
    }
    /// Save given entity and returns saved one
    public func save(entity: CSEntityProtocol) throws -> CSEntityProtocol {
        if type(of: self.view) == type(of: type(of: entity).view(self.view.database)) {
            var entityToSave = entity
            try self.view.db?.sql("LOCK TABLES `\(type(of: entity).tableName)` WRITE")
            if let modifiedEntity = entityToSave as? CSEntitySaveProtocol {
                type(of: modifiedEntity).saveModifier(entity: &entityToSave, view: self.view)
            }
            
            let savedEntity = try self.view.save(entity: entityToSave)
            try self.view.db?.sql("UNLOCK TABLES")
            return savedEntity
        }else{
            throw CSViewError.differentType
        }
    }
    public func save() throws -> CSEntityProtocol {
        return try self.save(entity: self.entity!)
    }
    /// Save given entity and load it
    public func saveAndLoad(entity: CSEntityProtocol) throws {
        self.entity = try self.save(entity: entity)
    }
    public func saveAndLoad() throws {
        self.entity = try self.save()
    }
    /// Recalculate entity
    public func recalculate(entity: CSEntityProtocol) -> CSEntityProtocol {
        if let recalculatable = self.view as? CSRecalculatedProtocol.Type {
            return recalculatable.recalculate(entity, view: self.view)
        }
        return entity
    }
}
public struct DecodableWrapper: Decodable {
    static var baseType: Decodable.Type!
    var base: Decodable

    public init(from decoder: Decoder) throws {
        self.base = try DecodableWrapper.baseType.init(from: decoder)
    }
}
public struct EncodableWrapper : Encodable {
    var value: Encodable?
    public init(_ value: Encodable?) {
        self.value = value
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try value?.encode(to: &container)
    }
}
public struct DeleteResponse: Encodable {
    let registerName: String
    let optionFieldName: String
    let refEntity: CSEntity
}
