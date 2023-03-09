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

class StocksMainViewController: UIViewController, StocksMainViewProtocol, UISearchControllerDelegate, UISearchBarDelegate {
    var presenter: StocksMainPresenterProtocol?
    
    private let primaryMenu = PrimaryMenu()
    @IBOutlet weak var tableView: UITableView!
    private let searchController = UISearchController(searchResultsController: nil)
    private var navBar = UINavigationBar(frame: CGRect(x: 20, y: 60, width: 340, height: 60))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        configSearchBar()
        addNavigationbar()
        presenter?.didLoad()
        setPrimaryMenuConstraints()
    }
    
    func configUI() {
        let nib = UINib(nibName: PropertyRowStock.reuseID, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: PropertyRowStock.reuseID)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.sectionHeaderHeight = 1
        
        primaryMenu.delegate = self
        primaryMenu.configure(with: ["Stocks", "Favorite"])
        
        view.addSubview(navBar)
        view.addSubview(primaryMenu)
    }
    
    func setPrimaryMenuConstraints() {
        primaryMenu.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 45).isActive = true
        primaryMenu.heightAnchor.constraint(equalToConstant: 35).isActive = true
        primaryMenu.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: -10).isActive = true
        primaryMenu.topAnchor.constraint(equalTo: navBar.bottomAnchor, constant: 10).isActive = true
    }
    
    func addNavigationbar() {
            let navigationItem = UINavigationItem(title: "")
            navigationItem.titleView = self.searchController.searchBar
            
            navBar.shadowImage = UIImage()
            navBar.setItems([navigationItem], animated: false)
            self.definesPresentationContext = true
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
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Find company or ticker"
        searchController.searchBar.backgroundColor = .white
        navigationItem.searchController?.searchBar.tintColor = .black
        self.definesPresentationContext = true
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

        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if isFiltering {
            return presenter?.filteredRows.count ?? 0
        }
        return presenter?.currentList.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PropertyRowStock.reuseID, for: indexPath) as! PropertyRowStock
        guard let presenter = presenter else { return cell }
        guard let model = self.presenter?.currentList else { return UITableViewCell() }
        
        if isFiltering {
            cell.config(with: presenter.filteredRows[indexPath.section])
        } else {
            cell.config(with: model[indexPath.section])
        }
        
        if indexPath.section % 2 != 0 {
            cell.setupColor(color: UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1.00))
        } else {
            cell.setupColor(color: UIColor(red: 0.94, green: 0.96, blue: 0.97, alpha: 1.00))
        }
        
        cell.changeColorDelta(value: model[indexPath.section].deltaProcent)
        cell.delegate = self

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let sectionSpacing: CGFloat = 1
        return sectionSpacing
    }
}


extension StocksMainViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        
        presenter?.filterContentForSearchText(text)
    }
}

extension StocksMainViewController: MenuStackDelegate {
    func changeMenu(index: Int) {
        presenter?.changeMenu(index: index)
    }
}

extension StocksMainViewController: TapFavoriteProtocol {
    func didTap(bool: Bool, name: String) {
        presenter?.changeIsFavorite(bool: bool, ticker: name)
    }
    
    
}
