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
    
    func path(for url: URL) -> URL
}

struct FileCache: FileCacheable {
    var directoryURL: URL = FileManager.default
        .urls(for: .cachesDirectory, in: .userDomainMask)
        .first!
    
    func save(_ data: Data, to url: URL) {
        let imageURL = path(for: url)
        try? data.write(to: imageURL)
    }
    
    func path(for url: URL) -> URL {
        let urlEncoded = url.absoluteString.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? ""
        return directoryURL.appendingPathComponent(urlEncoded)
    }
    
    func get(from url: URL) -> Data? {
        let imageURL = path(for: url)
        return try? Data(contentsOf: imageURL)
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
