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

    func test_init_doesNotPerformAnyURLRequest() {
        let (sut, cache) = makeSUT()

        XCTAssertEqual(cache.storage.count, 0, "Assumed to have no cache before first request")
    }
    
    func test_fetchValidURL_returnsImage() throws {
        //let (sut, loader) = makeSUT()
    }
     
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: CacheImageLoader, cache: MockFileCache) {
        let loader = ImageLoaderSpy()
        let cache = MockFileCache()
        let sut = CacheImageLoader(remoteLoader: loader, cache: cache)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(cache, file: file, line: line)
        return (sut, cache)
    }
}
