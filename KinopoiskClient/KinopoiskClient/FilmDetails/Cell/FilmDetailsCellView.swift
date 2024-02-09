//
//  FilmDetailsCellView.swift
//  KinopoiskClientClient
//
//  Created by Toto on 02.02.2024.
//

import UIKit

//MARK: - Film header view
class FilmDetailsHeaderCellView: UITableViewCell {
    @IBOutlet private var titleLabel: UILabel!
    
    @IBOutlet private var ratingLabel: UILabel!
    @IBOutlet private var ratingCount: UILabel!
    @IBOutlet private var creatorLabel: UILabel!
    
    @IBOutlet private var yearGenreLabel: UILabel!
    @IBOutlet private var countryLengthLabel: UILabel!
}

//MARK: - Film description view
class FilmDetailsDescriptionCellView: UITableViewCell {
    @IBOutlet private var descriptionLabel: UILabel!
}
