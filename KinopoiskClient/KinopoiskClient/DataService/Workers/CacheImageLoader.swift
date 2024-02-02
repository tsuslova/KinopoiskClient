//
//  CacheImageLoader.swift
//  KinopoiskClient
//
//  Created by Toto on 02.02.2024.
//

import Foundation
import Combine

//Cached Image data loader with Remote fallback
final class CacheImageLoader: ObservableObject {
    @Published var imageData: Data?
    
    private(set) var state: State
    
    private var cancellable: AnyCancellable?
    private let imageFetchingQueue = DispatchQueue(label: "imageFetching")
    
    private let loader: ImageLoader
    private let cache: FileCacheable
    private let imagesDirectoryURL: URL
    
    init(loader: ImageLoader = RemoteImageLoader(),
         cache: FileCacheable = FileCache()) {
        self.loader = loader
        self.cache = cache
        self.state = .none
        
        self.imagesDirectoryURL = cache.directoryURL
            .appendingPathComponent("images")
    }
    
    func fetch(from url: URL?) {
        guard state == .none, let url = url else { return }
        
        let imageURL = imagesDirectoryURL
            .appendingPathComponent(url.deletingPathExtension().lastPathComponent)
        
        if let cachedData = cache.get(from: imageURL){
            imageData = cachedData
            state = .success
            return
        }
        
        cancellable = loader.get(from: url)
            .subscribe(on: imageFetchingQueue)
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .handleEvents(
                receiveSubscription: { [weak self] _ in
                    self?.state = .loading
                },
                receiveOutput: { [weak self] imageData in
                    guard let imageData = imageData else { return }
                    try? self?.saveImageDataToCache(imageData, to: imageURL)
                })
            .sink(
                receiveCompletion: { [weak self] in
                    if case .failure = $0 {
                        self?.state = .failed
                    }
                }, receiveValue: { [weak self] image in
                    self?.imageData = image
                    self?.state = .success
                })
    }
    
    private func saveImageDataToCache(_ data: Data, to url: URL) throws {
        if !cache.fileExists(atPath: imagesDirectoryURL.path) {
            cache.createDirectory(atPath: imagesDirectoryURL.path)
        }
        self.cache.save(data, to: url)
    }
}

extension CacheImageLoader {
    enum State {
        case failed, none
        case loading
        case success
    }
}
