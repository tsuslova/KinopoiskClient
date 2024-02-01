//
//  FilmsResponseMapper.swift
//  Kinopoisk
//
//  Created by Toto on 01.08.2023.
//

import Foundation

internal final class FilmsResponseMapper {
    private struct FilmsResponse: Decodable {
        let total: Int
        let totalPages: Int
        let items: [FilmResponse]
    }
    
    private static let OK_200 = 200
    
    internal static func map(_ data: Data, response: URLResponse) throws -> [FilmResponse] {
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.isOK else {
            throw ServiceError.badRequest
        }
        guard let root = try? JSONDecoder().decode(FilmsResponse.self, from: data) else {
            throw ServiceError.invalidData
        }
        
        return root.items
    }
}
