//
//  HTTPClientSpy.swift
//  EssentialFeedTests
//
//  Created by Toto on 17.10.2023.
//

import Foundation
@testable import KinopoiskClient

//class HTTPClientSpy: HTTPClient {
//    private var messages = [(url: URL, completion: Result<(Data, HTTPURLResponse), Error> -> Void)]()
//    
//    var requestedURLs: [URL] {
//        return messages.map { $0.url }
//    }
//    
//    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
//        messages.append((url, completion))
//        return Task()
//    }
//    
//    func complete(with error: Error, index: Int = 0){
//        messages[index].completion(HTTPClient.Result.failure(error))
//    }
//    
//    func complete(withStatusCode code: Int, data: Data, index: Int = 0){
//        let response = HTTPURLResponse(url: requestedURLs[index],
//                                       statusCode: code,
//                                       httpVersion: nil,
//                                       headerFields: nil)!
//        messages[index].completion(HTTPClient.Result.success((data, response)))
//    }
//}
