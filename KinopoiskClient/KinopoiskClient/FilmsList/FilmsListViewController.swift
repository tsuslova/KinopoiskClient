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
    private var viewModelBindings = Set<AnyCancellable>()
    
    @IBOutlet weak var bottomRefreshControl: UIActivityIndicatorView!
    
    let searchTextSubject = PassthroughSubject<String, Never>()
    private var viewBindings = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModelToView()
        bindViewEvents()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        refreshTableViewData()
    }

    func bindViewModelToView() {
        listViewModel.$films
            .sink(receiveValue: { [weak self] films in
                guard let self else { return }
                print("listViewModel.$films receive \(films.count) films for page \(self.listViewModel.lastRequestedPage)")
                self.updateSections(films: films)
            })
            .store(in: &viewModelBindings)
        
        let stateValueHandler: (ListViewModelState) -> Void = { [weak self] state in
            switch state {
            case .loading:
                print(".loading")
                self?.startLoading()
            case .loadingFinished:
                print(".loadingFinished")
                self?.finishLoading()
            case .error(let error):
                print("error \(error)")
                //TODO: show error
                self?.finishLoading()
            }
        }
        listViewModel.$state
            .sink(receiveValue: stateValueHandler)
            .store(in: &viewModelBindings)
        listViewModel.$nextPageIsLoading
            .sink(receiveValue: { [weak bottomRefreshControl] in $0 ?  bottomRefreshControl?.startAnimating() :
                bottomRefreshControl?.stopAnimating()
            })
            .store(in: &viewModelBindings)
    }
    
    func bindViewEvents() {
        searchTextSubject
            .filter { $0.count > 2 }
            .throttle(for: 1.0, scheduler: RunLoop.main, latest: true)
            .sink { searchText in
                print("\(searchText)")
            } receiveValue: { [weak self] lastValue in
                print("lastValue = \(lastValue)")
                self?.listViewModel.search(text: lastValue)
            }.store(in: &viewBindings)

    }
    
    private func startLoading() {
        refreshControl?.beginRefreshing()
    }
    
    private func finishLoading() {
        refreshControl?.endRefreshing()
    }
    
    func refreshTableViewData() {
        var snapshot = Snapshot()
        snapshot.deleteAllItems()
        dataSource.apply(snapshot, animatingDifferences: false)
        
        listViewModel.reloadData()
    }
    
    private func updateSections(films: [Film]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.films])
        snapshot.appendItems(films)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

//MARK: - IBActions
extension FilmsListViewController {
    @IBAction func refreshList(_ sender: Any) {
        print("refreshList")
        refreshTableViewData()
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

extension FilmsListViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        print("prefetchRowsAt indexPaths \(indexPaths)")
        listViewModel.loadNextPageIfNeeded(for: indexPaths.map(\.row).max() ?? 0)
        
        //TODO: image pre-loading
    }
    
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        //TODO: cancel image pre-loading
    }
}

extension FilmsListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTextSubject.send(searchBar.text ?? "")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
}
