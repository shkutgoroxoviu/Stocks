//
//  ViewController.swift
//  Stocks
//
//  Created by Гурген Хоршикян on 18.01.2023.
//

import UIKit

protocol StocksMainViewProtocol: AnyObject {
    func reloadData()
}

class StocksMainViewController: UIViewController, StocksMainViewProtocol {
    var presenter: StocksMainPresenterProtocol?
    
    @IBOutlet weak var tableView: UITableView!
    private let searchController = UISearchController(searchResultsController: nil)
    
    func configUI() {
        let nib = UINib(nibName: PropertyRowStock.reuseID, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: PropertyRowStock.reuseID)
        tableView.delegate = self
        tableView.dataSource = self
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Find company or ticker"
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        configSearchBar()
        presenter?.didLoad()
    }
    
    private func configSearchBar() {
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.searchTextField.layer.cornerRadius = 18
        searchController.searchBar.searchTextField.layer.masksToBounds = true
        searchController.searchBar.searchTextField.backgroundColor = .white
        searchController.searchBar.searchTextField.borderStyle = .none
        searchController.searchBar.searchTextField.layer.borderWidth = 1
        searchController.searchBar.searchTextField.layer.borderColor = UIColor.black.cgColor
        searchController.searchBar.searchTextField.tintColor = .black
        searchController.searchBar.searchTextField.textColor = .black
        searchController.searchBar.tintColor = .black
        searchController.searchBar.setImage(UIImage(named: "search"), for: .search, state: .normal)
        searchController.searchBar.searchTextField.font = UIFont(name: "Montserrat-SemiBold", size: 16)
        
        navigationItem.titleView = searchController.searchBar
    }
    
    func reloadData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return  false }
        return text.isEmpty
    }
    
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
}

extension StocksMainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.rowModels.count ?? 0
}
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PropertyRowStock.reuseID, for: indexPath) as! PropertyRowStock
       
        guard let presenter = presenter?.rowModels[indexPath.row] else { return UITableViewCell() }
        
        cell.configName(with: presenter)
        
        return cell
    }
}

extension StocksMainViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
//        guard let text = searchController.searchBar.text else { return }
        
//        presenter?.filterContentForSearchText(text)
    }
}
