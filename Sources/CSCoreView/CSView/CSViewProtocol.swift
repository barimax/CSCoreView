//
//  CSViewProtocol.swift
//  CSCoreDB
//
//  Created by Georgie Ivanov on 18.08.19.
//
import Foundation
import PerfectCRUD

public protocol CSViewProtocol: Encodable, CSDatabaseProtocol, TableNameProvider {
    var refs: [String:String] { get }
    var registerName: String { get }
    var singleName: String { get }
    var pluralName: String { get }
    var fields: [CSPropertyDescription] { get }
    var searchableFields: [AnyKeyPath] { get }
    var refOptions: [String:CSRefOptionField] { get }
    var backRefs: [CSBackRefs] { get }
    
    var entity: Entity? { get set }
    var rows: [Entity]? { get set}
    
    
    mutating func loadAll() throws
    mutating func load(id: UInt64) throws
    mutating func save(entity: Entity) throws
    mutating func delete(id: UInt64) throws
    mutating func delete() throws
    

}

public extension CSViewProtocol {
    var refs: [String:String] {
        var res: [String:String] = [:]
        for field in self.fields {
            if let ref = field.ref {
                res[field.name] = ref.registerName
            }
        }
        return res
    }
}
public extension CSViewProtocol {
    func create() throws {
        try self.db?.create(Entity.self, policy: .shallow)
    }
    
    mutating func loadAll() throws {
        guard let entities = try self.table?.select().map({ $0 }) else {
            throw CSCoreDBError.entityNotFound
        }
        self.rows = entities
    }
    mutating func load(id: UInt64) throws {
        guard let entity: Entity = try self.table?.where(\Entity.id == id).first() else {
            throw CSCoreDBError.entityNotFound
        }
        self.entity = entity
    }
    mutating func save(entity: Entity) throws {
        var newEntity: Entity = entity
        if newEntity.id > 0 {
            try self.table?.where(\Entity.id == newEntity.id).update(newEntity)
        }else{
            guard let newId: UInt64 = try self.table?.insert(newEntity).lastInsertId() else {
                throw CSCoreDBError.saveError(message: "No new ID.")
            }
            newEntity.id = newId
        }
        self.entity = newEntity
    }
    mutating func delete(id: UInt64) throws {
        try self.table?.where(\Entity.id == id).delete()
        self.entity = nil
    }
    mutating func delete() throws {
        guard let entity = self.entity else {
            throw CSCoreDBError.deleteError
        }
        try self.delete(id: entity.id)
    }
}
public extension CSViewProtocol {
    var refOptions: [String:CSRefOptionField] {
        var result: [String:CSRefOptionField] = [:]
        
        for field in self.fields {
            if let ref = field.ref  {
                let refOption: CSRefOptionField = CSRefOptionField(
                    registerName: ref.registerName,
                    options: ref.options(),
                    isButton: false
                )
                result[field.name] = refOption
            }
        }
        return result
    }
    var backRefs: [CSBackRefs] {
        var res: [CSBackRefs] = []
        for (_,registerEntity) in CSRegister.store {
            if let entity = registerEntity as? CSEntityProtocol.Type {
                let view = entity.view()
                for (field, ref) in view.refs {
                    if ref == self.registerName {
                        var backRefs = CSBackRefs()
                        backRefs.registerName = view.registerName
                        backRefs.singleName = view.singleName
                        backRefs.pluralName = view.pluralName
                        backRefs.formField = field
                        res.append(backRefs)
                    }
                }
            }
        }
        return res
    }
}
