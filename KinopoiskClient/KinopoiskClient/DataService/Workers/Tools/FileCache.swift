//
//  FileCache.swift
//  KinopoiskClient
//
//  Created by Toto on 02.02.2024.
//

import Foundation

protocol FileCacheable {
    var directoryURL: URL { get }
    
    func save(_ data: Data, to path: URL)
    func get(from path: URL) -> Data?
    func remove(at path: URL)
    func fileExists(atPath path: String) -> Bool
    func createDirectory(atPath path: String)
}

struct FileCache: FileCacheable {
    var directoryURL: URL = FileManager.default
        .urls(for: .cachesDirectory, in: .userDomainMask)
        .first!
    
    func save(_ data: Data, to path: URL) {
        try? data.write(to: path)
    }
    
    func get(from path: URL) -> Data? {
        try? Data(contentsOf: path)
    }
    
    func remove(at path: URL) {
        try? FileManager.default.removeItem(at: path)
    }
    
    func fileExists(atPath path: String) -> Bool {
        FileManager.default.fileExists(atPath: path)
    }
    
    func createDirectory(atPath path: String) {
        try? FileManager.default.createDirectory(
            atPath: path,
            withIntermediateDirectories: true)
    }
}
