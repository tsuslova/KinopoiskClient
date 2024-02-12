//
//  FilmsResponseMapper.swift
//  Kinopoisk
//
//  Created by Toto on 01.08.2023.
//

import Foundation

func mapGeneric<Response: Decodable>(_ data: Data, response: URLResponse) throws -> Response {
    
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.isOK else {
        throw ServiceError.badRequest
    }
    guard let root = try? JSONDecoder().decode(Response.self, from: data) else {
        throw ServiceError.invalidData
    }
    
    return root
}

