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
    var responses: [URL:URLResponse] = [:]
    
    func responsePublisher(for url: URL) -> AnyPublisher<APIResponse, URLError>? {
        if let error = errors[url] {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
        
        //TODO check the save completion results instead
        let data = anyData()
        let response = okResponse(for: url)
        requestedURLs.append(url)
        
        return Just((data: data, response: response))
                    .setFailureType(to: URLError.self)
                    .eraseToAnyPublisher()
    }
    
    func dataTaskPublisher(for url: URL) -> URLSession.DataTaskPublisher? {
        return nil
    }
    
    func dataTaskPublisher(for url: URL, parameters: [String: Any]) -> URLSession.DataTaskPublisher? {
        return dataTaskPublisher(for: url)
    }
    
    func completeLoading(url: URL, with error: URLError){
        errors[url] = error
    }
    
    func completeLoading(url: URL, withStatusCode code: Int, data: Data, index: Int = 0){
//        let response = HTTPURLResponse(url: requestedURLs[index],
//                                       statusCode: code,
//                                       httpVersion: nil,
//                                       headerFields: nil)!
//        messages[index].completion(HTTPClient.Result.success((data, response)))
    }
}
