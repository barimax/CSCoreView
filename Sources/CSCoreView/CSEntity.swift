//
//  CSEntity.swift
//  CSCoreDB
//
//  Created by Georgie Ivanov on 22.08.19.
//

import Foundation
import CSCoreDB

struct CSEntity: CSDBEntityProtocol {
    static var tableName: String = ""
    static var singleName: String = "Client"
    static var pluralName: String = "Clients"
    var id: Int = 0
}



