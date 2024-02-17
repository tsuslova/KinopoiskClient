//
//  RemoteImageLoaderTests.swift
//  KinopoiskClientTests
//
//  Created by Toto on 13.02.2024.
//

import XCTest
@testable import KinopoiskClient

final class RemoteImageLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertEqual(client.requestedURLs.count, 0, "Expected to have no requested URL before first request")
    }
    
    func test_get_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT()
        
        _ = sut.get(from: url)
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_getURLTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT()
        
        _ = sut.get(from: url)
        _ = sut.get(from: url)
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_getURL_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        let url = anyURL()
        
        client.completeLoading(requestIndex: 0, with: URLError(.unknown))
    
        let expectation = expectation(description: "Wait for loading completion")
        let _ = sut.get(from: url)
            .sink { completion in
                if case .failure = completion {
                    expectation.fulfill()
                } else {
                    XCTFail("Waiting for an error. Got success")
                }
            } receiveValue: { data in
                XCTFail("Waiting for an error. Got data")
            }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_getURL_succeedsOnHTTPURLResponseWithData() {
        let (sut, client) = makeSUT()
        
        let url = anyURL()
        let data = anyData()
        
        let expectation = expectation(description: "Wait for completion")
        
        client.completeLoading(requestIndex: 0, withStatusCode: 200, data: data)
        
        let _ = sut.get(from: url)
            .sink { _ in } receiveValue: { receivedData in
                XCTAssertEqual(receivedData, data, "Waiting for data returned from HTTPClient")
                
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: ImageLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteImageLoader(client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }
}
