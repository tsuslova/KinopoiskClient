//
//  FilmDetailsHeaderCellView.swift
//  KinopoiskClient
//
//  Created by Toto on 02.02.2024.
//

import UIKit
import Combine

//MARK: - Film header view
class FilmDetailsHeaderCellView: UITableViewCell {
    @IBOutlet private var logoImageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    
    @IBOutlet private var ratingLabel: UILabel!
    @IBOutlet private var ratingCountLabel: UILabel!
    @IBOutlet private var nameOriginalLabel: UILabel!
    
    @IBOutlet private var yearGenreLabel: UILabel!
    @IBOutlet private var countryLengthLabel: UILabel!
    
    private var bindings = Set<AnyCancellable>()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
    }
    
    var viewModel: FilmDetailsViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            viewModelChanged(viewModel)
        }
    }
    
    func viewModelChanged(_ viewModel: FilmDetailsViewModel) {
        self.titleLabel.text = ""
        viewModel.$logoReplacingText
            .sink { text in
                self.titleLabel.text = text
            }.store(in: &bindings)
        
        logoImageView.image = nil
        viewModel.$logoImageData
            .compactMap { $0 }
            .map { UIImage(data: $0) }
            .sink { [weak logoImageView] image in
                logoImageView?.image = image
            }
            .store(in: &bindings)
        ratingLabel.text = viewModel.rating()
        ratingLabel.textColor = viewModel.ratingTextColor()
    }
}
