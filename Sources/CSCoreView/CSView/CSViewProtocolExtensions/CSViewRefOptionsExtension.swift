//
//  CSViewRefOptionsExtension.swift
//  CSCoreDB
//
//  Created by Georgie Ivanov on 23.08.19.
//

import Foundation
import PerfectCRUD
import PerfectMySQL

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
    var refOptions: [String:CSRefOptionField] {
        var result: [String:CSRefOptionField] = [:]
        
        for field in self.fields {
            if let ref = field.ref  {
                print("JORO: ViewProtocol: \(ref.options().count)")
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
        for (_,entity) in CSRegister.store {
            let view = entity.view()
            for (field, ref) in view.refs {
                if ref == Self.registerName {
                    var backRefs = CSBackRefs()
                    backRefs.registerName = type(of: view).registerName
                    backRefs.singleName = view.singleName
                    backRefs.pluralName = view.pluralName
                    backRefs.formField = field
                    res.append(backRefs)
                }
            }
        }
        return res
    }
}
