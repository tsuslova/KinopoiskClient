//
//  RemoteImageLoader.swift
//  KinopoiskClient
//
//  Created by Toto on 01.02.2024.
//

import Foundation
import Combine

protocol ImageLoader: AnyObject {
    func get(from url: URL) -> AnyPublisher<Data?, URLError>
}

final class RemoteImageLoader: ImageLoader {
    private let client: HTTPClient
    
    init(client: HTTPClient = URLSessionHTTPClient()){
        self.client = client
    }
    
    func get(from url: URL) -> AnyPublisher<Data?, URLError> {
        guard let publisher = client.responsePublisher(for: url) else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        return publisher
            .map { $0.data }
            .eraseToAnyPublisher()
    }
}
