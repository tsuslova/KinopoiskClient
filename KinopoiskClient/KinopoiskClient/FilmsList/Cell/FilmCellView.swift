//
//  FilmCellView.swift
//  KinopoiskClient
//
//  Created by Toto on 01.02.2024.
//

import UIKit
import Combine

final class FilmCellView: UITableViewCell {
    static let identifier = "FilmCellView"
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var posterImageView: UIImageView!
    
    private var bindings = Set<AnyCancellable>()
    
    var viewModel: FilmCellViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            viewModelChanged(viewModel)
        }
    }
    
    func viewModelChanged(_ viewModel: FilmCellViewModel) {
        titleLabel.text = viewModel.title
        descriptionLabel.text = viewModel.description
        viewModel.$posterImageData
            .receive(on: RunLoop.main)
            .compactMap { $0 }
            .map { UIImage(data: $0) }
            .sink { [weak posterImageView] image in
                posterImageView?.image = image
            }
            .store(in: &bindings)
    }

}
