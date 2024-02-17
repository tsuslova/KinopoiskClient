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
    
    
    func test_getFilms_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        let expectation = expectation(description: "Wait for load completion")
        let page = 1
        let error = URLError(.unknown)
        
        client.completeLoading(requestIndex: 0, with: error)
        
        let _ = sut.get(page: page, keyword: nil)
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
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FilmsService, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFilmsService(client: client)
       
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
   }
}
