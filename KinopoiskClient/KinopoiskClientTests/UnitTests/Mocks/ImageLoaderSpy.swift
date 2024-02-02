//
//  ImageLoaderSpy.swift
//  KinopoiskTests
//
//  Created by Toto on 31.01.2024.
//
@testable import KinopoiskClient
import Combine
import UIKit.UIImage

class ImageLoaderSpy: ImageLoader {
    private(set) var requestedURLs = [URL]()
    
    func get(from url: URL) -> AnyPublisher<Data?, URLError> {
        requestedURLs.append(url)
        
        let data = anyData()
        
        return Just(data)
            .setFailureType(to: URLError.self)
            .eraseToAnyPublisher()
    }
}
