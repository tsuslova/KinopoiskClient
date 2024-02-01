//
//  RemoteFilmsLoader.swift
//  Kinopoisk
//
//  Created by Toto on 21.07.2023.
//

import Foundation
import Combine

//TODO: normal router
enum NetworkRouter {
    static var filmsPath: String { "films" }
    
    static func baseUrl() -> URL {
        URL(string: "https://kinopoiskapiunofficial.tech/api/v2.2")!
    }

    static func api(_ name: String) -> URL {
        baseUrl().appendingPathComponent(name)
    }
 
    static func filmsAPI() -> URL {
        return api(filmsPath)
    }
}

final class RemoteFilmsService: FilmsService {
    private let client: HTTPClient
    
    public init(client: HTTPClient){
        self.client = client
    }
    
    func get(page: Int) -> AnyPublisher<[Film], ServiceError> {
        guard page >= KinopoiskDefaults.firstPage else {
            print("You know that's Kinopoisk... Pagination starts from 1.")
            return Fail(error: ServiceError.badRequest)
                .eraseToAnyPublisher()
        }
        
        let url = NetworkRouter.filmsAPI()
        let parameters = FilmsRequest(page: page).compactDictionaryRepresentation
        return client.dataTaskPublisher(for: url, parameters: parameters)
            .tryMap(FilmsResponseMapper.map)
            .map { $0.toModels() }
            .mapError(ServiceError.map)
            .eraseToAnyPublisher()
    }
}

extension Array where Element == FilmResponse {
    func toModels() -> [Film] {
        map { Film(filmResponse: $0) }
    }
}
