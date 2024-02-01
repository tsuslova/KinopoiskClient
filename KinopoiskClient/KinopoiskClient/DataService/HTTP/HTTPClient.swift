//
//  HTTPClient.swift
//  Kinopoisk
//
//  Created by Toto on 01.08.2023.
//

import Foundation

//Wrapper for URLSessionDataTask to reduce dependencies from URLSession library
//from client's code
public protocol Task {
    func cancel()
    func resume()
}

public protocol HTTPClient {
    func dataTaskPublisher(for url: URL, parameters: [String: Any]) -> URLSession.DataTaskPublisher
}

extension URLSessionDataTask: Task {}
