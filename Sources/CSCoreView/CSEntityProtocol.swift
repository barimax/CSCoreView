//
//  CSEntityProtocol.swift
//  CSCoreDB
//
//  Created by Georgie Ivanov on 22.08.19.
//

import Foundation
import PerfectCRUD

public protocol CSEntityProtocol: Codable {
    var id: UInt64 { get set }
    static func view() -> CSView
}
