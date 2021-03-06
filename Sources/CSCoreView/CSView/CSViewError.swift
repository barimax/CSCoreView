//
//  CSViewError.swift
//  CSCoreDB
//
//  Created by Georgie Ivanov on 22.08.19.
//

public enum CSViewError: Error {
    case jsonError
    case registerError(message: String)
    case findError
    case searchError
    case noEntity
    case differentType
    case dynamicFieldError
}

