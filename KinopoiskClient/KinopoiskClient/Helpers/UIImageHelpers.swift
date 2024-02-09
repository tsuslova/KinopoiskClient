//
//  UIImageHelpers.swift
//  KinopoiskClient
//
//  Created by Toto on 09.02.2024.
//

import UIKit

extension UIImage {
    func crop(to targetSize: CGSize) -> UIImage {
        let croppedCGImage = cgImage!.cropping(
            to: CGRect(origin: CGPointZero, size: targetSize)
        )!

        let croppedImage = UIImage(
            cgImage: croppedCGImage,
            scale: self.imageRendererFormat.scale,
            orientation: self.imageOrientation
        )
        return croppedImage
    }
}
