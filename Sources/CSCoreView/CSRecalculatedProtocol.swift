//
//  CSRecalculatedProtocol.swift
//  CSCoreView
//
//  Created by Georgie Ivanov on 1.11.19.
//

import Foundation

public protocol CSRecalculatedProtocol {
    static func recalculate(_ source: CSEntityProtocol, view: inout CSViewProtocol) -> CSEntityProtocol
    static var recalcultionTriggers: [String] { get }
}
