//
//  FilmDetailsCoverView.swift
//  KinopoiskClient
//
//  Created by Toto on 05.02.2024.
//

import UIKit
import Combine

class FilmDetailsCoverView: UIView {
    @IBOutlet weak var coverImageView: UIImageView!
//    @IBOutlet weak var posterImageSuperview: UIView!
    @IBOutlet weak var blackOverlayView: UIView!
    
    private var imageBinding: AnyCancellable?
    
    private var initialImageHeight: CGFloat?
    
    weak var viewModel: FilmDetailsViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            viewModelChanged(viewModel)
            initializeImageHeightConstraint()
        }
    }
    
    private func viewModelChanged(_ viewModel: FilmDetailsViewModel) {
        coverImageView.image = nil
        imageBinding = viewModel.$coverImageData
            .compactMap { $0 }
            .map { UIImage(data: $0) }
            .compactMap { $0 }
            .map({ image in
                let size = image.size.width
                return image.crop(to: CGSize(width: size, height: size))
            })
            .sink { [weak coverImageView] image in
                coverImageView?.image = image
            }
    }
    
    func update(yOffset: CGFloat) {
        guard let imageHeight = imageHeightConstraint else {
            print("Error: need constraint with 'imageHeight' identifier")
            return
        }
        if initialImageHeight == nil {
            initialImageHeight = imageHeight.constant
        }
        
        if yOffset < 0 {
            imageHeight.constant = initialImageHeight! - yOffset
        } else {
            blackOverlayView.alpha = yOffset / initialImageHeight!
        }
    }
    
    var imageHeightConstraint: NSLayoutConstraint? {
        get {
            constraints.filter({ $0.identifier == "imageHeight" }).first
        }
    }
    
    func initializeImageHeightConstraint() {
        imageHeightConstraint?.constant = self.bounds.width
    }
}
