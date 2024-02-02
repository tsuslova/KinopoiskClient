//
//  CacheImageLoaderTests.swift
//  KinopoiskClientTests
//
//  Created by Toto on 02.02.2024.
//

import XCTest
import Combine
@testable import KinopoiskClient

final class CacheImageLoaderTests: XCTestCase {
    var bindings = Set<AnyCancellable>()
    
    func test_init_doesNotPerformAnyURLRequest() {
        let (_, loader, cache) = makeSUT()

        XCTAssertEqual(loader.requestedURLs.count, 0, "Expected to have no requested URL before first request")
        XCTAssertEqual(cache.storage.count, 0, "Expected to have no cache before first request")
    }
    
    func test_fetchValidURL_returnsImage() throws {
        let (sut, loader, cache) = makeSUT()
        let url = anyURL()
        
        let expectation = expectation(description: "Load image")
        
        sut.$imageData
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                XCTFail()
            }, receiveValue: { _ in
                expectation.fulfill()
            })
            .store(in: &bindings)
        
        sut.fetch(from: url)
        
        wait(for: [expectation], timeout: 1)
        
        XCTAssertNotNil(sut.imageData, "Expected to load image data")
        XCTAssertEqual(sut.state, CacheImageLoader.State.success, "Expected image fetching state is .success")
        
        XCTAssertEqual(loader.requestedURLs.count, 1, "Expected to load 1 image on loading 1 URL")
        XCTAssertEqual(cache.storage.count, 1, "Expected to cache 1 image on loading 1 URL")
    }
     
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: CacheImageLoader, loader: ImageLoaderSpy, cache: MockFileCache) {
        let loader = ImageLoaderSpy()
        let cache = MockFileCache()
        let sut = CacheImageLoader(remoteLoader: loader, cache: cache)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(cache, file: file, line: line)
        return (sut, loader, cache)
    }
}
