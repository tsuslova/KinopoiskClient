//
//  RemoteImageLoader.swift
//  KinopoiskClient
//
//  Created by Toto on 01.02.2024.
//

import Foundation
import Combine

protocol ImageLoader {
    func get(from url: URL) -> AnyPublisher<Data, URLError>
}

final class RemoteImageLoader: ImageLoader {
    private let client: HTTPClient
    
    init(client: HTTPClient){
        self.client = client
    }
    
    func get(from url: URL) -> AnyPublisher<Data, URLError> {
        client.dataTaskPublisher(for: url, parameters: [:])
            .map { $0.data }
            .eraseToAnyPublisher()
    }
}
