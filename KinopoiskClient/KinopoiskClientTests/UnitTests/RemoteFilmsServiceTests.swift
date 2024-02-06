//
//  RemoteFilmsServiceTests.swift
//  KinopoiskClientTests
//
//  Created by Toto on 06.02.2024.
//

import XCTest
@testable import KinopoiskClient

final class RemoteFilmsServiceTests: XCTestCase {

    func test_init_doesNotPerformAnyURLRequest() {
        let (_, client) = makeSUT()
        
        XCTAssertEqual(client.requestedURLs.count, 0, "Expected to have no requested URL before first request")
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FilmsService, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFilmsService()
       
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
   }
}
