//
//  FilmDetailsViewController.swift
//  KinopoiskClientClient
//
//  Created by Toto on 02.02.2024.
//

import UIKit
import Combine

final class FilmDetailsViewController: UIViewController {
    var film: Film! {
        didSet {
            viewModel = makeViewModel()
        }
    }
    var viewModel: FilmDetailsViewModel!
    @IBOutlet private var coverImageView: FilmDetailsCoverView!
    @IBOutlet private var tableView: UITableView!
    
    private var viewModelBindings = Set<AnyCancellable>()
    
    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarAppearance()
        setUpBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        makeNavigationBarBackgroundClear()
        insetTableViewToFillNavigationBarArea()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        restoreNavigationBarToDefault()
    }
    
    //MARK: - UI setup
    private func setupNavigationBarAppearance() {
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.topItem?.title = " "
    }
    
    private func setUpBindings() {
        setUpTableViewScrollingBindings()
        
        viewModel.$film.sink { [weak coverImageView] film in
            guard let coverUrlString = film.coverUrl,
                let coverUrl = URL(string: coverUrlString) else {
                //TODO adjust UI to hide the image??
                //Or load posterURL and adjust it to rectangular aspect ratio
                return
            }
            coverImageView?.viewModel = ImageViewModel(imageURL: coverUrl)
        }.store(in: &viewModelBindings)
    }
    
    var scrollBinding: Cancellable?
    private func setUpTableViewScrollingBindings() {
        scrollBinding = tableView.publisher(for: \.contentOffset)
//            .filter { $0.y < 0 }
            .sink(receiveValue: { offset in
                self.coverImageView.update(yOffset: offset.y)
            })

    }
}

//MARK: - Private setup
private extension FilmDetailsViewController {
    func makeViewModel() -> FilmDetailsViewModel {
        FilmDetailsViewModel(film: film, filmsService: RemoteFilmsService())
    }
}

private extension FilmDetailsViewController {
    
    func makeNavigationBarBackgroundClear() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
    }
    
    func restoreNavigationBarToDefault() {
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil
    }
    
    func insetTableViewToFillNavigationBarArea() {
        let yOffset = UIApplication.shared.statusBarHeight + self.navigationController!.navigationBar.frame.size.height
        tableView.contentInset = UIEdgeInsets(top: -yOffset, left: 0, bottom: 0, right: 0)
    }
}

//UITableViewController
extension FilmDetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        15
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilmDetailsHeaderCellView", for: indexPath) as! FilmDetailsHeaderCellView
        cell.backgroundColor = .black
        return cell
    }
}
