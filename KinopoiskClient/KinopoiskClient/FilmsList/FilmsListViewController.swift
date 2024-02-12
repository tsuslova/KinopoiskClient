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
    
    private var cellsViewModels = [IndexPath: FilmCellViewModel]()
    
    @IBOutlet weak var bottomRefreshControl: UIActivityIndicatorView!
    
    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModelToView()
        bindViewEvents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBarAppearance()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isLoadingFirstTime() {
            refreshTableViewData()
        }
    }
    
    //MARK: - View setup
    private func bindViewModelToView() {
        listViewModel.$films
            .sink(receiveValue: { [weak self] films in
                guard let self else { return }
                self.updateSections(films: films)
            })
            .store(in: &viewModelBindings)
        
        let stateValueHandler: (ListViewModelState) -> Void = { [weak self] state in
            switch state {
            case .loading:
                self?.startLoading()
            case .loadingFinished:
                self?.finishLoading()
            case .error(let error):
                //TODO: show error
                print("Error: \(error)")
                self?.showError()
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
    
    private func bindViewEvents() {
        searchTextSubject
            .filter { $0.count > 1 }
            .sink (receiveValue: { [weak self] searchText in
                self?.listViewModel.search(text: searchText)
            }).store(in: &viewBindings)
    }
    
    private func setupNavigationBarAppearance() {
        navigationController?.isNavigationBarHidden = true
        navigationController?.navigationBar.topItem?.title = " "
    }
    
    //MARK: - Intrinsic logic
    private func startLoading() {
        if tableView.contentOffset.y < tableView.frame.height {
            refreshControl?.beginRefreshing()
        }
    }
    
    private func showError() {
        showAlertMessage(title: "Ошибка загрузки данных", message: "Вероятно, Вы не добавили APIKey или же лимит загрузок на сегодня исчерпан.")
    }
    
    private func finishLoading() {
        refreshControl?.endRefreshing()
    }
    
    private func refreshTableViewData() {
        let snapshot = makeSnapshot()
        dataSource.apply(snapshot, animatingDifferences: false)

        listViewModel.reloadData()
    }
    
    private func isLoadingFirstTime() -> Bool {
        cellsViewModels.count == 0
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
        refreshTableViewData()
    }
}

//MARK: - TableView Datasource
private extension FilmsListViewController {
    private func makeDataSource() -> UITableViewDiffableDataSource<FilmsListViewModel.Section, Film> {
        return UITableViewDiffableDataSource(tableView: tableView, cellProvider: {
            [weak self] tableView, indexPath, film in
            let cell = tableView.dequeueReusableCell(
                withIdentifier: FilmCellView.identifier,
                for: indexPath) as! FilmCellView
            cell.viewModel = self?.makeOrGetCellViewModel(for: indexPath, film: film)
            return cell
        })
    }
    
    private func makeOrGetCellViewModel(for indexPath: IndexPath, film: Film) -> FilmCellViewModel {
        if let vm = cellsViewModels[indexPath]{
            if vm.checkViewModelIsFor(film: film) {
                return vm
            } else {
                vm.cancelLoading()
            }
        }
        let vm = FilmCellViewModel(film: film)
        cellsViewModels[indexPath] = vm
        return vm
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
        listViewModel.loadNextPageIfNeeded(for: indexPaths.map(\.row).max() ?? 0)
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { cellsViewModels[$0]?.cancelLoading() }
        
    }
}

//MARK: - UISearchBarDelegate
extension FilmsListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
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

//MARK: - UITableViewDelegate
extension FilmsListViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let film = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
            
        let storyboard = UIStoryboard(name: "FilmDetails", bundle: nil)
        if let filmDetailsVC = storyboard.instantiateViewController(withIdentifier: "FilmDetailsViewController") as? FilmDetailsViewController {
            filmDetailsVC.initializeViewModel(with: film)
            navigationController?.pushViewController(filmDetailsVC, animated: true)
        }
    }
}
