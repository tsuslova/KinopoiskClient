//
//  FilmsListViewController.swift
//  KinopoiskClient
//
//  Created by Toto on 01.02.2024.
//
import UIKit
import Combine

final class FilmsListViewController: UITableViewController {
    private typealias DataSource = UITableViewDiffableDataSource<FilmsListViewModel.Section, Film>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<FilmsListViewModel.Section, Film>
    private lazy var dataSource = makeDataSource()
    
    //TODO: move model, service & client initialization away from VC
    private var listViewModel = FilmsListViewModel(filmsService: RemoteFilmsService(client: URLSessionHTTPClient()))
    private var bindings = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModelToView()
        refresh()
    }

    func bindViewModelToView() {
        listViewModel.$films
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] films in
                self?.updateSections()
            })
            .store(in: &bindings)
        
        let stateValueHandler: (ListViewModelState) -> Void = { [weak self] state in
            switch state {
            case .loading:
                self?.startLoading()
            case .loadingFinished:
                self?.finishLoading()
            case .error:
                //TODO: show error
                self?.finishLoading()
            }
        }
        listViewModel.$state
            .receive(on: RunLoop.main)
            .sink(receiveValue: stateValueHandler)
            .store(in: &bindings)
        
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    private func startLoading() {
        refreshControl?.beginRefreshing()
    }
    
    private func finishLoading() {
        refreshControl?.endRefreshing()
    }
    
    @objc func refresh() {
        listViewModel.loadFilms()
    }
    
    private func updateSections() {
        var snapshot = Snapshot()
        snapshot.appendSections([.films])
        snapshot.appendItems(listViewModel.films)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
}

//MARK: - IBActions
extension FilmsListViewController {
    @IBAction func refreshList(_ sender: Any) {
        startLoading()
    }
}

//MARK: - TableView Datasource
private extension FilmsListViewController {
    private func makeDataSource() -> DataSource {
        return UITableViewDiffableDataSource(tableView: tableView, cellProvider: { tableView, indexPath, film in
            let cell = tableView.dequeueReusableCell(
                withIdentifier: FilmCellView.identifier,
                for: indexPath) as! FilmCellView
            cell.viewModel = FilmCellViewModel(film: film)
            return cell
        })
        
    }
}
