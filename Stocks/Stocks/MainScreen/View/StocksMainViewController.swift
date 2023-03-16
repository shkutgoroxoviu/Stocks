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
    private var navBar = UINavigationBar()
    private var refreshControl = UIRefreshControl()
    
    var lastContentOffset: CGFloat = 0
    var currentIndex: Int = 0

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
        tableView.addSubview(refreshControl)
        tableView.backgroundColor = .white
        
        searchController.searchBar.delegate = self
        
        primaryMenu.backgroundColor = .white
        primaryMenu.delegate = self
        primaryMenu.configure(with: ["Stocks", "Favorite"])
        
        refreshControl.addTarget(self, action: #selector(refreshTable(_:)), for: .valueChanged)
        
        view.addSubview(navBar)
        view.addSubview(primaryMenu)
    }
    
    @objc func refreshTable(_ sender: AnyObject) {
       if currentIndex == 0 {
            presenter?.didLoad()
       } else {
           
       }
            refreshControl.endRefreshing()
        }
    
    func setPrimaryMenuConstraints() {
        primaryMenu.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 35).isActive = true
        primaryMenu.heightAnchor.constraint(equalToConstant: 35).isActive = true
        primaryMenu.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: -5).isActive = true
        primaryMenu.topAnchor.constraint(equalTo: navBar.bottomAnchor, constant: 10).isActive = true
    }
    
    func changeCoordPrimaryMenu(value: CGFloat) {
        UIView.animate(withDuration: 0.5) {
            self.primaryMenu.topAnchor.constraint(equalTo: self.navBar.bottomAnchor, constant: value).isActive = true
            self.primaryMenu.layoutIfNeeded()
        }
    }
    
    func changeCoordNavBar(value: Int) {
        UIView.animate(withDuration: 0.5) {
            self.navBar.frame = CGRect(x: 30, y: value, width: Int(self.tableView.frame.width), height: 60)
        }
    }
    
    func addNavigationbar() {
        let navigationItem = UINavigationItem(title: "")
        navigationItem.titleView = self.searchController.searchBar
        
        navBar.frame = CGRect(x: 30, y: 60, width: view.frame.width - 64, height: 60)
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
        searchController.searchBar.setImage(UIImage(named: "cancel"), for: .clear, state: .normal)
        searchController.searchBar.searchTextField.font = UIFont(name: "Montserrat-SemiBold", size: 16)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Find company or ticker"
        searchController.searchBar.backgroundColor = .white
        searchController.searchBar.showsCancelButton = false
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
    
    //MARK: Delete
        func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
            if searchController.isActive {
                return .none
            } else {
                return .delete
            }
        }
        
        func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                guard let model = presenter?.rowModels[indexPath.section] else { return }
                presenter?.deleteStock(at: model.tickerName)
                let indexSet = IndexSet(arrayLiteral: indexPath.section)
                tableView.deleteSections(indexSet, with: .fade)
            }
        }
}

extension StocksMainViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetY = scrollView.contentOffset.y
        
        if contentOffsetY > lastContentOffset && lastContentOffset >= 0 || contentOffsetY > 900 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.changeCoordNavBar(value: 0)
                self.changeCoordPrimaryMenu(value: 10)
                self.navBar.isHidden = true
            }
        } else if lastContentOffset <= -0.33333333333333337 || contentOffsetY < lastContentOffset {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.changeCoordNavBar(value: 60)
                self.changeCoordPrimaryMenu(value: 10)
                self.navBar.isHidden = false
            }
        }
        lastContentOffset = contentOffsetY
        
        if searchController.searchBar.isFirstResponder {
            searchController.searchBar.resignFirstResponder()
            searchController.isActive = false
        }
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
        self.currentIndex = index
        presenter?.changeMenu(index: index)
    }
}

extension StocksMainViewController: TapFavoriteProtocol {
    func didTap(bool: Bool, name: String) {
        presenter?.changeIsFavorite(bool: bool, ticker: name)
    }
}

extension StocksMainViewController{
    func didPresentSearchController(searchController: UISearchController) {
            self.searchController.searchBar.becomeFirstResponder()
    }
}
