//
//  FilmDetailsViewController.swift
//  KinopoiskClient
//
//  Created by Toto on 02.02.2024.
//

import UIKit
import Combine

final class FilmDetailsViewController: UIViewController {
    private var viewModel: FilmDetailsViewModel?
    
    @IBOutlet private var coverImageView: FilmDetailsCoverView!
    @IBOutlet private var tableView: UITableView!
    
    private var viewModelBindings = Set<AnyCancellable>()
    
    private var headerCell: FilmDetailsHeaderCellView?
    
    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarAppearance()
        setUpBindings()
        
        viewModel?.loadFilmDetails()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        makeNavigationBarBackgroundClear()
        setupTableView()
        setupHeaderSize()
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
        coverImageView.viewModel = viewModel
        setUpTableViewScrollingBindings()
        
        if let viewModel = viewModel {
            Publishers.CombineLatest(
                viewModel.$logoImageData.eraseToAnyPublisher(),
                viewModel.$logoReplacingText.eraseToAnyPublisher())
            .sink { _ in
                self.headerCell?.setNeedsLayout()
                self.headerCell?.layoutIfNeeded()
            }.store(in: &viewModelBindings)
        }
    }
    
    var scrollBinding: Cancellable?
    private func setUpTableViewScrollingBindings() {
        scrollBinding = tableView.publisher(for: \.contentOffset)
            .sink(receiveValue: { offset in
                self.coverImageView.update(yOffset: offset.y)
            })
    }
    
    private func setupHeaderSize() {
        let headerSize = tableView.frame.size.width
        tableView.tableHeaderView?.frame = CGRect(x: 0, y: 0, width: headerSize, height: headerSize)
    }
    
    private func setupTableView() {
        tableView.rowHeight = UITableView.automaticDimension
        insetTableViewToFillNavigationBarArea()
    }
}

//MARK: - Private setup
extension FilmDetailsViewController {
    func initializeViewModel(with film: Film) {
        viewModel = FilmDetailsViewModel(film: film, filmsService: RemoteFilmsService())
    }
}

//MARK: - Fill navigation bar area with table content
extension FilmDetailsViewController {
    
    private func makeNavigationBarBackgroundClear() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
    }
    
    private func restoreNavigationBarToDefault() {
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil
    }
    
    private func insetTableViewToFillNavigationBarArea() {
        let yOffset = UIApplication.shared.statusBarHeight + self.navigationController!.navigationBar.frame.size.height
        tableView.contentInset = UIEdgeInsets(top: -yOffset, left: 0, bottom: 0, right: 0)
    }
}

//MARK: - UITableViewDataSource
extension FilmDetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch  indexPath.row {
        case 0:
            return filmDetailsHeaderCell(tableView)
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FilmDetailsDescriptionCellView", for: indexPath) as! FilmDetailsDescriptionCellView
            return cell
        }
    }
    
    private func filmDetailsHeaderCell(_ tableView: UITableView) -> FilmDetailsHeaderCellView {
        if let headerCell = headerCell {
            return headerCell
        }
        
        guard let viewModel = viewModel else { fatalError() }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilmDetailsHeaderCellView") as! FilmDetailsHeaderCellView
        cell.viewModel = viewModel
        headerCell = cell
        return cell
    }
}
