//
//  FilmCellView.swift
//  KinopoiskClient
//
//  Created by Toto on 01.02.2024.
//

import UIKit

final class FilmCellView: UITableViewCell {
    static let identifier = "FilmCellView"
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var posterImageView: UIImageView!
    
    var viewModel: FilmCellViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            viewModelChanged(viewModel)
        }
    }
    
    func viewModelChanged(_ viewModel: FilmCellViewModel) {
        //TODO fill the interface with data from viewModel
    }

}
