//
//  HTTPClientSpy.swift
//  EssentialFeedTests
//
//  Created by Toto on 17.10.2023.
//

import Foundation
import Combine
@testable import KinopoiskClient

protocol URLSessionProtocol {
    typealias APIResponse = URLSession.DataTaskPublisher.Output
    func response(for request: URLRequest) -> AnyPublisher<APIResponse, URLError>
}

class HTTPClientSpy: HTTPClient {
    var requestedURLs: [URL] = []
    var errors: [URL:URLError] = [:]
    var responses: [URL:(URLResponse, Data)] = [:]
    
    func responsePublisher(for url: URL) -> AnyPublisher<APIResponse, URLError>? {
        requestedURLs.append(url)

        if let error = errors[url] {
            errors[url] = nil
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        if let (response, data) = responses[url] {
            responses[url] = nil
            return Just((data: data, response: response))
                .setFailureType(to: URLError.self)
                .eraseToAnyPublisher()
        }
        
        //print("Possible error: no expected response/error set for url: \(url)")
        return nil
    }
    
    func dataTaskPublisher(for url: URL) -> URLSession.DataTaskPublisher? {
        return nil
    }
    
    func dataTaskPublisher(for url: URL, parameters: [String: Any]) -> URLSession.DataTaskPublisher? {
        return dataTaskPublisher(for: url)
    }
    
    //Spying
    func completeLoading(url: URL, with error: URLError){
        errors[url] = error
    }
    
    func completeLoading(url: URL, withStatusCode code: Int, data: Data){
        let response = HTTPURLResponse(url: url,
                                       statusCode: code,
                                       httpVersion: nil,
                                       headerFields: nil)!
        responses[url] = (response, data)
    }
}
