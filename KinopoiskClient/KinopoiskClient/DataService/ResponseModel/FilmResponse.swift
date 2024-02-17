//
//  FilmResponse.swift
//  Kinopoisk
//
//  Created by Toto on 08.12.2023.
//

import Foundation

struct CountryResponse: Codable, Equatable, Hashable {
    let country: String
}
struct GenreResponse: Codable, Equatable, Hashable {
    let genre: String
}

struct FilmsResponse: Codable {
    let total: Int
    let totalPages: Int
    let items: [FilmResponse]
}

struct FilmResponse: Codable, Hashable {
    let kinopoiskId: Int
    let nameRu: String?
    let posterUrl: String
    let posterUrlPreview: String
    let ratingKinopoisk: Float?
    
    let countries: [CountryResponse]?
    let genres: [GenreResponse]?
    let year: Int?
    
    static func map(_ data: Data, response: URLResponse) throws -> [FilmResponse] {
        let resp: FilmsResponse = try mapGeneric(data, response: response)
        return resp.items
    }

}
