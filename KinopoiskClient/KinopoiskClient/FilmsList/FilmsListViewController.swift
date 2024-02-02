//
//  FilmsListViewController.swift
//  KinopoiskClient
//
//  Created by Toto on 01.02.2024.
//
import UIKit
import Combine

final class FilmsListViewController: UITableViewController {
    private lazy var dataSource = makeDataSource()
    
    private lazy var listViewModel = makeViewModel()
    private var viewModelBindings = Set<AnyCancellable>()
    
    private let searchTextSubject = PassthroughSubject<String, Never>()
    private var viewBindings = Set<AnyCancellable>()
    
    @IBOutlet weak var bottomRefreshControl: UIActivityIndicatorView!
    
    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModelToView()
        bindViewEvents()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        refreshTableViewData()
    }

    //MARK: - View setup
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
            .filter { $0.count > 1 }
            .sink (receiveValue: { [weak self] searchText in
                print("lastValue = \(searchText)")
                self?.listViewModel.search(text: searchText)
            }).store(in: &viewBindings)
    }
    
    private func startLoading() {
        refreshControl?.beginRefreshing()
    }
    
    private func finishLoading() {
        refreshControl?.endRefreshing()
    }
    
    private func refreshTableViewData() {
        var snapshot = makeSnapshot()
        dataSource.apply(snapshot, animatingDifferences: false)
        
        listViewModel.reloadData()
    }
    
    private func updateSections(films: [Film]) {
        var snapshot = makeSnapshot()
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
    private func makeDataSource() -> UITableViewDiffableDataSource<FilmsListViewModel.Section, Film> {
        return UITableViewDiffableDataSource(tableView: tableView, cellProvider: { tableView, indexPath, film in
            let cell = tableView.dequeueReusableCell(
                withIdentifier: FilmCellView.identifier,
                for: indexPath) as! FilmCellView
            cell.viewModel = FilmCellViewModel(film: film)
            return cell
        })
    }
}

//MARK: - Private setup
private extension FilmsListViewController {
    func makeViewModel() -> FilmsListViewModel {
        FilmsListViewModel(filmsService: RemoteFilmsService())
    }
    
    func makeSnapshot() -> NSDiffableDataSourceSnapshot<FilmsListViewModel.Section, Film> {
        NSDiffableDataSourceSnapshot<FilmsListViewModel.Section, Film>()
    }
}

//MARK: - UITableViewDataSourcePrefetching
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

//MARK: - UISearchBarDelegate
extension FilmsListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("textDidChange")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchTextSubject.send(searchBar.text ?? "")
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        refreshTableViewData()
    }
}
