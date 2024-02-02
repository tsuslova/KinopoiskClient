//
//  MockFileCache.swift
//  KinopoiskTests
//
//  Created by Toto on 31.01.2024.
//

@testable import KinopoiskClient
import Foundation

class MockFileCache: FileCacheable {
    var directoryURL: URL = anyURL()
    
    var storage: [(String, Data)] = []
    
    init(with stub: [(String, Data)] = []) {
        self.storage = stub
    }
    
    func save(_ data: Data, to path: URL) {
        storage.append((path.absoluteString, data))
    }
    
    func get(from path: URL) -> Data? {
        storage.first { $0.0 == path.absoluteString }?.1
    }
    
    func remove(at path: URL) {
        storage.removeAll { $0.0 == path.absoluteString }
    }
    
    func fileExists(atPath path: String) -> Bool {
        storage.contains { $0.0 == path }
    }
    
    func createDirectory(atPath path: String) {
    }
}
