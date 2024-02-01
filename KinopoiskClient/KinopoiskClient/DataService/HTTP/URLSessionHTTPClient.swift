//
//  URLSessionHTTPClient.swift
//  Kinopoisk
//
//  Created by Toto on 08.08.2023.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    
    public lazy var session: URLSession = {
        URLSession(configuration: configuration)
    }()
    
    private let configuration: URLSessionConfiguration
    
    public init(configuration: URLSessionConfiguration = URLSessionConfiguration.default){
        self.configuration = configuration
        setupSessionConfiguration()
    }
    
    public func dataTaskPublisher(for url: URL, parameters: [String: Any]) -> URLSession.DataTaskPublisher? {
        guard let request = getUrlRequest(with: url, parameters: parameters) else {
            return nil
        }
        return session.dataTaskPublisher(for: request)
    }
    
    // MARK: - Setup
    private func setupSessionConfiguration() {
        if configuration.httpAdditionalHeaders == nil {
            configuration.httpAdditionalHeaders = [:]
        }
        configuration.httpAdditionalHeaders?[.accept] = String.jsonMimeType
    }
    
    private func makeUrl(from url: URL, parameters: [String: Any]) -> URL? {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }

        return components.url
    }
    
    private func getUrlRequest(with url: URL, parameters: [String: Any]) -> URLRequest? {
        guard let url = makeUrl(from: url, parameters: parameters) else {
            return nil
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.timeoutInterval = .defaultRequestTimeout
        urlRequest.httpMethod = .get
        
        return urlRequest
    }
}

private extension String {
    static let jsonMimeType = "application/json"
    static let get = "GET"
    static let post = "POST"
    static let apiKey = "X-API-KEY"
    static let contentType = "Content-Type"
}

private extension AnyHashable {
    static let accept = "Accept"
}

private extension TimeInterval {
    static var defaultRequestTimeout = 60.0
}
