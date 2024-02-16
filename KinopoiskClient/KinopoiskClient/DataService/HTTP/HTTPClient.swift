//
//  HTTPClient.swift
//  Kinopoisk
//
//  Created by Toto on 01.08.2023.
//

import Foundation
import Combine
public protocol HTTPClient {
    typealias APIResponse = URLSession.DataTaskPublisher.Output
    func responsePublisher(for url: URL) -> AnyPublisher<APIResponse, URLError>?
    func responsePublisher(for url: URL, parameters: [String: Any]) -> AnyPublisher<APIResponse, URLError>?
}
