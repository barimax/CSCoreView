//
//  CSCustomOptionsProtocol.swift
//  CSCoreView
//
//  Created by Georgie Ivanov on 30.10.19.
//

import Foundation

public protocol CSCustomOptionsProtocol {
    var customOptions: [AnyKeyPath: () -> [UInt64: String]] { get }
}
