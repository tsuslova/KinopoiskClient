//
//  FilmDetailsCellView.swift
//  KinopoiskClientClient
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
        viewModel.$logoReplacingText
            .sink { text in
                if let text = text {
                    //TODO add the titleLabel.text = text
                } else {
                    //TODO hide the label
                }
            }.store(in: &bindings)
        
        logoImageView.image = nil
        viewModel.$logoImageData
            .compactMap { $0 }
            .map { UIImage(data: $0) }
            .sink { [weak logoImageView] image in
                logoImageView?.image = image
            }
            .store(in: &bindings)
    }
}
