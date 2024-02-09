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
    //I use 'Data' here instead of 'UIImage' to leave canonical UI-independant
    //presentation layer approach (potentially we could use this code in a
    //cross-platform app e.g. with MacOS's NSImage)
    //Of course that might look abstrusely here and in small iOS-only app I would
    //rather prefer UIImage here instead of Data
    @Published var imageData: Data?
    @Published var isImageLoading: Bool = false
    
    private(set) var state: State
    
    private var cancellable: AnyCancellable?
    private let imageFetchingQueue = DispatchQueue(label: "imageFetching")
    
    private let loader: ImageLoader
    private let cache: FileCacheable
    
    //MARK: - Interface
    init(remoteLoader: ImageLoader = RemoteImageLoader(),
         cache: FileCacheable = FileCache()) {
        self.loader = remoteLoader
        self.cache = cache
        self.state = .none
    }
    
    func fetch(from url: URL?) {
        guard state == .none, let url = url else { return }
        
        if !loadFromCache(url: url){
            requestFromLoader(url: url)
        }
    }
    
    private func loadFromCache(url: URL) -> Bool {
        if let cachedData = cache.get(from: url){
            imageData = cachedData
            state = .success
            return true
        }
        return false
    }
    
    private func requestFromLoader(url: URL) {
        if isImageLoading {
            cancelLoading()
        }
        isImageLoading = true
        
        cancellable = loader.get(from: url)
            .subscribe(on: imageFetchingQueue)
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .handleEvents(
                receiveSubscription: { [weak self] _ in
                    self?.state = .loading
                    self?.isImageLoading = false
                },
                receiveOutput: { [weak self] imageData in
                    guard let imageData = imageData else { return }
                    try? self?.saveImageDataToCache(imageData, to: url)
                })
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure = completion {
                        self?.state = .failed
                    }
                }, receiveValue: { [weak self] image in
                    self?.imageData = image
                    self?.state = .success
                })
    }

    func cancelLoading() {
        cancellable = nil
    }

    //MARK: - Intrinsic logic
    private func saveImageDataToCache(_ data: Data, to url: URL) throws {
        if !cache.fileExists(atPath: cache.directoryURL.path) {
            cache.createDirectory(atPath: cache.directoryURL.path)
        }
        self.cache.save(data, to: url)
    }
}

//MARK: - Loading state
extension CacheImageLoader {
    enum State {
        case failed, none
        case loading
        case success
    }
}
