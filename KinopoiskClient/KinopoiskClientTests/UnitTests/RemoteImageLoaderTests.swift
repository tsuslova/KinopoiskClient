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
    
    // MARK: - Helpers
        
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: ImageLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteImageLoader(client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }

}
