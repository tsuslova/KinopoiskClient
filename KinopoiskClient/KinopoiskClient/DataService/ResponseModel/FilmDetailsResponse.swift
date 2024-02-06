//
//  FilmDetailsResponse.swift
//  KinopoiskClient
//
//  Created by Toto on 06.02.2024.
//

import Foundation

struct FilmDetailsResponse: Decodable, Hashable {
    let kinopoiskId: Int
    let nameRu: String?
    let posterUrl: String
    let coverUrl: String
    let posterUrlPreview: String
    let ratingKinopoisk: Float?
    
    let countries: [CountryResponse]
    let genres: [GenreResponse]
    let year: Int
    
    static func map(_ data: Data, response: URLResponse) throws -> FilmDetailsResponse {
        let resp: FilmDetailsResponse = try mapGeneric(data, response: response)
        return resp
    }
}
