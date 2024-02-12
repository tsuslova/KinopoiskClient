//
//  FilmDetailsCellView.swift
//  KinopoiskClient
//
//  Created by Toto on 12.02.2024.
//

import UIKit

class FilmDetailsCellView: UITableViewCell {
    var viewModel: FilmDetailsViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            viewModelChanged(viewModel)
        }
    }
    
    func viewModelChanged(_ viewModel: FilmDetailsViewModel) {
        //Part of template method - to be implemented in descedants
    }
}
