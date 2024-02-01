//
//  FilmsListViewController.swift
//  KinopoiskClient
//
//  Created by Toto on 01.02.2024.
//

import UIKit
import Combine

final class FilmsListViewController: UITableViewController {
    private var listViewModel = FilmsListViewModel()
    private var bindings = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func bindViewModelToView() {
        listViewModel.$films
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .store(in: &bindings)
        
        let stateValueHandler: (ListViewModelState) -> Void = { [weak self] state in
            switch state {
            case .loading:
                self?.startLoading()
            case .loadingFinished:
                self?.finishLoading()
            case .error:
                //TODO
                self?.finishLoading()
            }
        }
        
        listViewModel.$state
            .receive(on: RunLoop.main)
            .sink(receiveValue: stateValueHandler)
            .store(in: &bindings)
    }
    
    private func startLoading() {
        refreshControl?.beginRefreshing()
    }
    
    private func finishLoading() {
        refreshControl?.endRefreshing()
        tableView.reloadData()
    }

}

//MARK: - IBActions
extension FilmsListViewController {
    @IBAction func refreshList(_ sender: Any) {
        startLoading()
    }
}

//MARK: - TableView Datasource
extension FilmsListViewController {
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //TODO: binding
        return listViewModel.films.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //TODO: initialization with cell view model
        let cell = tableView.dequeueReusableCell(
            withIdentifier: FilmCellView.identifier,
            for: indexPath) as! FilmCellView
        cell.viewModel = FilmCellViewModel()
        return cell
    }
}
