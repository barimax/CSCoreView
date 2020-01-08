//
//  CSViewRefOptionsExtension.swift
//  CSCoreDB
//
//  Created by Georgie Ivanov on 23.08.19.
//

import Foundation
import PerfectCRUD
import PerfectMySQL

extension CSViewProtocol {
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
            if field.fieldType != .dynamicFormControl {
                if let ref = field.ref  {
                    if let customOptionsObject = ref as? CSCustomOptionsProtocol,
                        let customOptions = customOptionsObject.customOptions(keyPath: field.keyPath) {
                        let refOption: CSRefOptionField = CSRefOptionField(
                            registerName: ref.registerName,
                            options: customOptions,
                            isButton: ref.isButton
                        )
                        result[field.name] = refOption
                    }else{
                        let refOption: CSRefOptionField = CSRefOptionField(
                            registerName: ref.registerName,
                            options: ref.options(self.database),
                            isButton: ref.isButton
                        )
                        result[field.name] = refOption
                    }
                }
            }
        }
        return result
    }
    var refViews: [String: [CSDynamicEntityPropertyDescription]] {
        var result: [String: [CSDynamicEntityPropertyDescription]] = [:]
        for field in self.fields {
            if let ref = field.ref, let dynamicRef = ref as? CSDynamicFieldProtocol.Type  {
                result[field.name] = dynamicRef.fields
            }
        }
        return result
    }
    var backRefs: [CSBackRefs] {
        var res: [CSBackRefs] = []
        for (_,entity) in CSRegister.store {
            let view = entity.view(self.database)
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
        return res
    }
}
