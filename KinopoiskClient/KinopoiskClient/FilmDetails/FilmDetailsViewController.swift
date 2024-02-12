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
    
    private var headerCell: FilmDetailsCellView?
    
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
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.setBackIndicatorImage(UIImage(named: "backIcon"), transitionMaskImage: UIImage(named: "backIcon"))
        navigationController?.navigationBar.standardAppearance = appearance
    }
    
    private func setUpBindings() {
        coverImageView.viewModel = viewModel
        setUpTableViewScrollingBindings()
        
        guard let viewModel = viewModel else { return }
        
        Publishers.CombineLatest(
            viewModel.$logoImageData.eraseToAnyPublisher(),
            viewModel.$logoReplacingText.eraseToAnyPublisher())
        .sink { _ in
            self.headerCell?.setNeedsLayout()
            self.headerCell?.layoutIfNeeded()
        }.store(in: &viewModelBindings)
        
        Publishers.Merge(viewModel.$shortDescription, viewModel.$description)
            .sink { publisher in
                self.tableView.reloadData()
                self.tableView.tableFooterView?.backgroundColor = viewModel.footerColor()
            }.store(in: &viewModelBindings)
        
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
        self.tableView.tableFooterView?.backgroundColor = .clear
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
        tableView.contentInset = UIEdgeInsets(top: -yOffset, left: 0, bottom: -yOffset, right: 0)
    }
}

//MARK: - UITableViewDataSource
extension FilmDetailsViewController: UITableViewDataSource {
    enum FilmDetailsCellType: Int, CaseIterable {
        case header = 0
        case description = 1
        
        var identifier: String{
            switch self {
            case .header:
                return "FilmDetailsHeaderCellView"
            case .description:
                return "FilmDetailsDescriptionCellView"
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        FilmDetailsCellType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellType = FilmDetailsCellType(rawValue: indexPath.row) else {
            fatalError("It looks like I try add rows without declaring them in enum")
        }
        
        switch cellType {
        case .header:
            return filmDetailsHeaderCell(tableView)
        case .description:
            return detailsCell(tableView, cellType: cellType)
        }
    }
    
    private func filmDetailsHeaderCell(_ tableView: UITableView) -> FilmDetailsCellView {
        if let headerCell = headerCell {
            return headerCell
        }
        
        let cell = detailsCell(tableView, cellType: .header)
        headerCell = cell
        return cell
    }
    
    private func detailsCell(_ tableView: UITableView, cellType: FilmDetailsCellType) -> FilmDetailsCellView {
        guard let viewModel = viewModel else {
            fatalError("FilmDetailsViewController's viewModel not set")
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellType.identifier) as! FilmDetailsCellView
        cell.viewModel = viewModel
        return cell
    }
}
