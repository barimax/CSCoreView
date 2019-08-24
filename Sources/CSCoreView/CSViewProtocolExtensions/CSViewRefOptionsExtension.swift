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
            if let ref = field.ref {
                let options: [Int:String] = ref.options()
                let refOption: CSRefOptionField = CSRefOptionField(
                    registerName: type(of:ref).registerName,
                    options: options,
                    isButton: false
                )
                result[field.name] = refOption
            }
        }
        return result
    }
    public var backRefs: [CSBackRefs] {
        var res: [CSBackRefs] = []
        return res
    }
}
//                var skip: Bool = false
//                var tempRef: CSRefOptionField<Entity>?
//                for (_,r) in result {
//                    if(r.registerName == ref.registerName){
//                        skip = true
//                        tempRef = r
//                    }
//                }
//                if(skip){
//                    skip = false
//                    if let t = tempRef {
//                        result[field.name] = t
//                        tempRef = nil
//                    }
//                }else{
//                    if let entity = Register.registerStore[ref.registerName]  {
//                        let options: [Int:String] = ref
                        // fix! works only for event price
//                        if registerName == BMEvent.registerName && classRegisterName == BMService.registerName {
//
//                        }
                        // EOF fix!
//                        var refOptions: CSRefOptionField = CSRefOptionField(
//                            registerName: entity.registerName,
//                            options: options,
//                            isButton: false,
//                            view: nil
//                        )
//                        if let entityIsView = entity as? BMViewDelegate {
//                            refOptions.isButton = true
//                            if entity is BMDynamicDelegate {
//                                refOptions.view = entityIsView.view()
//                            }
//                            if let entityIsSP = entityIsView as? BMSpecialOptionsProtocol {
//                                let view = entityIsView.view()
//                                view.isSP = true
//                                view.spIdName = entityIsSP.spIdName
//                                refOptions.view = view
//                            }
//                        }
//                        result[field] = refOptions
//                    }
//                }
//            }
//
//        }
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
//        return result
//    }
//}
extension CSView {
    func options<T: CSEntityProtocol>(type: T.Type) -> [Int:String] where T:CSOptionableProtocol {
        typealias T = Entity
        var res: [Int: String] = [:]
        print(type.optionField)
        do {
            let queryResult = try table.select().map { ($0.id, $0[keyPath: type.optionField] ) }
            for (k,v) in queryResult {
                res[k] = v as? String
            }
        } catch {
            print(error)
        }
       
        return res
    }
}
