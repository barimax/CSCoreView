//
//  CSViewRefOptionsExtension.swift
//  CSCoreDB
//
//  Created by Georgie Ivanov on 23.08.19.
//

import Foundation
import CSCoreDB

public extension CSViewProtocol {
    public var refOptions: [String:CSRefOptionField] {
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
    public var backRefs: [CSBackRefs] {
        var res: [CSBackRefs] = []
        for (_,registerEntity) in Register.registerStore {
            if let entity = registerEntity as? CSBaseEntityProtocol.Type {
                for (field, ref) in entity.refs {
                    if ref == self.registerName {
                        var backRefs = CSBackRefs()
                        backRefs.registerName = entity.registerName
                        backRefs.singleName = entity.singleName
                        backRefs.pluralName = entity.pluralName
                        backRefs.formField = field
                        res.append(backRefs)
                    }
                }
            }
        }
        return res
    }
}
