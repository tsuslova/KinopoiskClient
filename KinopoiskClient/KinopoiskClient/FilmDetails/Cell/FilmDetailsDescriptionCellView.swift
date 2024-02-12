//
//  FilmDetailsDescriptionCellView.swift
//  Kinopoisk
//
//  Created by Toto on 08.02.2024.
//

import UIKit
import Combine

//MARK: - Film description view
class FilmDetailsDescriptionCellView: FilmDetailsCellView {
    @IBOutlet private var shortDescriptionLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    
    private var bindings = Set<AnyCancellable>()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
    }
    
    override func viewModelChanged(_ viewModel: FilmDetailsViewModel) {
        self.shortDescriptionLabel.text = ""
        self.descriptionLabel.text = ""
        
        viewModel.$film
            .sink { [weak self] film in
                guard let self else { return }
                self.backgroundColor = viewModel.showDescriptionCell(for: film) ?
                    .white : .clear
                self.shortDescriptionLabel.text = film.shortDescription
                self.descriptionLabel.text = film.description
            }
            .store(in: &bindings)
    }
}
