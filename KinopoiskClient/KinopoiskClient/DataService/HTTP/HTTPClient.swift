//
//  HTTPClient.swift
//  Kinopoisk
//
//  Created by Toto on 01.08.2023.
//

import Foundation
import Combine
public protocol HTTPClient {
    func dataTaskPublisher(for url: URL) -> URLSession.DataTaskPublisher?
    func dataTaskPublisher(for url: URL, parameters: [String: Any]) -> URLSession.DataTaskPublisher?
    
    typealias APIResponse = URLSession.DataTaskPublisher.Output
    func responsePublisher(for url: URL) -> AnyPublisher<APIResponse, URLError>?
}
