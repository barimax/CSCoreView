//
//  CSViewRefOptionsExtension.swift
//  CSCoreDB
//
//  Created by Georgie Ivanov on 23.08.19.
//

import Foundation
extension CSViewProtocol {
    var refOptions: [String:CSRefOptionField<Entity>] {
        var result: [String:CSRefOptionField<Entity>] = [:]
        for field in self.fields {
            var skip: Bool = false //???
            var tempRef: CSRefOptionField<Entity>?
            for (_,r) in result {
//                if(r.registerName == classRegisterName){
//                    skip = true
//                    tempRef = r
//                }
            }
        }
//        for (field, classRegisterName) in self.refs {
//            var skip: Bool = false
//            var tempRef: RefOptionField?
//            for (_,r) in result {
//                if(r.registerName == classRegisterName){
//                    skip = true
//                    tempRef = r
//                }
//            }
//            if(skip){
//                skip = false
//                if let t = tempRef {
//                    result[field] = t
//                    tempRef = nil
//                }
//            }else{
//                if let entity = BMRegister.allMenuItems[classRegisterName] as? BMOptionableDelegate {
//                    let options: [Int:String] = entity.options()
//                    // fix! works only for event price
//                    if registerName == BMEvent.registerName && classRegisterName == BMService.registerName {
//                        
//                    }
//                    // EOF fix!
//                    var refOptions: RefOptionField = RefOptionField(registerName: entity.registerName, options: options, isButton: false, view: nil)
//                    if let entityIsView = entity as? BMViewDelegate {
//                        refOptions.isButton = true
//                        if entity is BMDynamicDelegate {
//                            refOptions.view = entityIsView.view()
//                        }
//                        if let entityIsSP = entityIsView as? BMSpecialOptionsProtocol {
//                            let view = entityIsView.view()
//                            view.isSP = true
//                            view.spIdName = entityIsSP.spIdName
//                            refOptions.view = view
//                        }
//                    }
//                    result[field] = refOptions
//                }
//            }
//        }
        return result
    }
}
