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
    var errors: [Int: URLError] = [:]
    var responses: [Int: (Int, Data)] = [:]
    
    func responsePublisher(for url: URL) -> AnyPublisher<APIResponse, URLError>? {
        return responsePublisher(for: url, parameters: [:])
    }
    
    func responsePublisher(for url: URL, parameters: [String: Any]) -> AnyPublisher<APIResponse, URLError>? {
        requestedURLs.append(url)
        
        guard let requestIndex = requestedURLs.firstIndex(of: url) else {
            print("Possible error: no expected response/error set for url: \(url)")
            return nil
        }
//        print("requestIndex = \(requestIndex)")
//        print("errors = \(errors)")
        if let error = errors[requestIndex] {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        if let (statusCode, data) = responses[requestIndex],
            let response = HTTPURLResponse(url: url,
                                           statusCode: statusCode,
                                           httpVersion: nil,
                                           headerFields: nil) {
            return Just((data: data, response: response))
                .setFailureType(to: URLError.self)
                .eraseToAnyPublisher()
        }
        
        return nil
    }
    
    //Spying
    func completeLoading(requestIndex: Int, with error: URLError){
        errors[requestIndex] = error
    }
    
    func completeLoading(requestIndex: Int, withStatusCode code: Int, data: Data){
        responses[requestIndex] = (code, data)
    }
}
