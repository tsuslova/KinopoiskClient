//
//  RemoteFilmsLoader.swift
//  Kinopoisk
//
//  Created by Toto on 21.07.2023.
//

import Foundation
import Combine

final class RemoteFilmsService: FilmsService {
    private let client: HTTPClient
    
    public init(client: HTTPClient = URLSessionHTTPClient()){
        self.client = client
    }
    
    func get(page: Int) -> AnyPublisher<[Film], ServiceError> {
        let url = FilmsAPIEndpoint.root.url
        let parameters = FilmsRequest(page: page)
        
        return filmsDataPublisher(url: url, parameters: parameters)
    }
    
    func get(page: Int, keyword: String?) -> AnyPublisher<[Film], ServiceError> {
        guard page >= KinopoiskDefaults.firstPage else {
            print("You know that's Kinopoisk... Pagination starts from 1.")
            return Fail(error: ServiceError.badRequest)
                .eraseToAnyPublisher()
        }
        let url: URL
        let parameters: CompactDictionaryRepresentable
        
        if let keyword = keyword{
            url = FilmsAPIEndpoint.search.url
            parameters = SearchFilmsRequest(page: page, keyword: keyword)
        } else {
            url = FilmsAPIEndpoint.root.url
            parameters = FilmsRequest(page: page)
        }
        
        return filmsDataPublisher(url: url, parameters: parameters)
    }
        
    func filmsDataPublisher(url: URL, parameters: CompactDictionaryRepresentable) -> AnyPublisher<[Film], ServiceError> {
        //print("url \(url), parameters = \(parameters)")
        guard let publisher = client.dataTaskPublisher(for: url, parameters: parameters.compactDictionaryRepresentation) else {
            return Fail(error: ServiceError.badRequest)
                .eraseToAnyPublisher()
        }
        return publisher
            .tryMap(FilmResponse.map)
            .map { $0.toModels() }
            .mapError(ServiceError.map)
            .eraseToAnyPublisher()
    }
    
    func getDetails(filmId: Int) -> AnyPublisher<Film, ServiceError> {
        let url = FilmsAPIEndpoint.details(filmId: filmId).url
        
        guard let publisher = client.dataTaskPublisher(for: url) else {
            return Fail(error: ServiceError.badRequest)
                .eraseToAnyPublisher()
        }
        return publisher
            .tryMap(FilmDetailsResponse.map)
            .map { Film(filmDetailsResponse: $0) }
            .mapError(ServiceError.map)
            .eraseToAnyPublisher()
    }
}

extension Array where Element == FilmResponse {
    func toModels() -> [Film] {
        map { Film(filmResponse: $0) }
    }
}
