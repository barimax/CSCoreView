//
//  CSEntityProtocol.swift
//  CSCoreDB
//
//  Created by Georgie Ivanov on 18.08.19.
//

import Foundation
import PerfectCRUD

public protocol CSDBEntityProtocol: Codable, TableNameProvider {
    var id: UInt64 { get set }
}
