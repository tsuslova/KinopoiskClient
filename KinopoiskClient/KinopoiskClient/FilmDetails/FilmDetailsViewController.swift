//
//  FilmDetailsViewController.swift
//  KinopoiskClientClient
//
//  Created by Toto on 02.02.2024.
//

import UIKit
import Combine

final class FilmDetailsViewController: UITableViewController {    
    var film: Film! {
        didSet {
            viewModel = makeViewModel()
        }
    }
    var viewModel: FilmDetailsViewModel!
    
    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarAppearance()
    }
    
    //MARK: - UI setup
    private func setupNavigationBarAppearance() {
        navigationController?.navigationBar.topItem?.title = " "
    }
}

//MARK: - Private setup
private extension FilmDetailsViewController {
    func makeViewModel() -> FilmDetailsViewModel {
        FilmDetailsViewModel(film: film)
    }
}
