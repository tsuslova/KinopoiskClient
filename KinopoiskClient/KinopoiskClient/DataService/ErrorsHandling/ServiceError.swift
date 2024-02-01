//
//  ServiceError.swift
//  Kinopoisk
//
//  Created by Toto on 29.01.2024.
//

import Foundation

enum ServiceError: Error {
    case connectivity
    case invalidData
    case badRequest
    case generic
    
    
    internal static func map(_ error: Error) -> ServiceError {
        switch error {
        case let serviceError as ServiceError:
              return serviceError
        default:
              return .generic
        }
    }
}
