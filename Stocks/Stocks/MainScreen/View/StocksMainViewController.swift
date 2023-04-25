//
//  ViewController.swift
//  Stocks
//
//  Created by Гурген Хоршикян on 18.01.2023.
//

import UIKit

protocol StocksMainViewProtocol: AnyObject {
    func reloadData()
    func openSearchVC(vc: UIViewController)
    func openDetailedVC(vc: UIViewController)
}

class StocksMainViewController: UIViewController, StocksMainViewProtocol, UISearchControllerDelegate, UISearchBarDelegate {
    var presenter: StocksMainPresenterProtocol?
    
    private let primaryMenu = PrimaryMenu()
    @IBOutlet weak var tableView: UITableView!
    private let searchController = UISearchController(searchResultsController: nil)
    private var refreshControl = UIRefreshControl()
    
    var cornerRadiusDict: [IndexPath: CGFloat] = [:]
    var currentIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        configSearchBar()
        setPrimaryMenuConstraints()
        presenter?.didLoad()
        createGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        detectedCurrentIndex()
    }
    
    func detectedCurrentIndex() {
        if currentIndex == 0 {
            presenter?.didLoad()
        } else {
            presenter?.favoriteModels = []
            presenter?.didTapFavoriteMenuItem()
        }
    }

    func configUI() {
        let nib = UINib(nibName: PropertyRowStock.reuseID, bundle: nil)
        let headerFooterView = UIView()
        tableView.register(nib, forCellReuseIdentifier: PropertyRowStock.reuseID)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.sectionHeaderHeight = 1
        tableView.addSubview(refreshControl)
        tableView.backgroundColor = .white
        tableView.tableHeaderView?.alpha = 0.0
        tableView.sectionIndexBackgroundColor = .white
        tableView.showsVerticalScrollIndicator = false
        
        headerFooterView.backgroundColor = .clear
        UITableViewHeaderFooterView.appearance().backgroundView = headerFooterView
        
        navigationItem.searchController = searchController
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = .white
        
        searchController.searchBar.delegate = self
        searchController.delegate = self

        primaryMenu.backgroundColor = .white
        primaryMenu.delegate = self
        primaryMenu.configure(with: ["Stocks", "Favorite"])
        
        refreshControl.addTarget(self, action: #selector(refreshTable(_:)), for: .valueChanged)
        
        view.addSubview(primaryMenu)
    }

    func createGestureRecognizer() {
        let swipeleft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeleft.direction = .left
        self.view.addGestureRecognizer(swipeleft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeDown.direction = .up
        self.view.addGestureRecognizer(swipeDown)
    }
    
    @objc func handleSwipe(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .left {
            presenter?.changeMenu(index: 1)
            currentIndex = 1
            primaryMenu.forceUpdatePosition(1)
        } else {
            presenter?.changeMenu(index: 0)
            currentIndex = 0
            primaryMenu.forceUpdatePosition(0)
        }
        
//        if sender.direction == .up {
//            searchController.searchBar.resignFirstResponder()
//            presenter?.changeMenu(index: 0)
//            primaryMenu.forceUpdatePosition(0)
//        } else if sender.direction == .down {
//            searchController.searchBar.resignFirstResponder()
//            presenter?.changeMenu(index: 0)
//            primaryMenu.forceUpdatePosition(0)
//        }
    }
    
    @objc func refreshTable(_ sender: AnyObject) {
        if currentIndex == 0 {
            presenter?.didLoad()
        } else {
            presenter?.refreshFavoriteMenu()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.tableView.contentInset = UIEdgeInsets(top: self.refreshControl.frame.height, left: 0, bottom: 0, right: 0)
            self.refreshControl.endRefreshing()
            self.tableView.contentInset = .zero
        }
    }
    
    func setPrimaryMenuConstraints() {
        primaryMenu.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        primaryMenu.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        primaryMenu.heightAnchor.constraint(equalToConstant: 25).isActive = true
        primaryMenu.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: -25).isActive = true
    }
    
    private func configSearchBar() {
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont(name: "Montserrat-SemiBold", size: 16) as Any
        ]
        searchController.searchBar.searchBarStyle = .default
        searchController.searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchController.definesPresentationContext = true
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
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Find company or ticker", attributes: attributes)
        searchController.searchBar.backgroundColor = .white
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.showsCancelButton = false
        searchController.searchBar.clearsContextBeforeDrawing = true
        
        navigationItem.titleView?.backgroundColor = .white
        navigationItem.searchController?.searchBar.tintColor = .black
    }
    
    func openSearchVC(vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func openDetailedVC(vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func reloadData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension StocksMainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return presenter?.currentList.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PropertyRowStock.reuseID, for: indexPath) as! PropertyRowStock
        guard let model = self.presenter?.currentList else { return UITableViewCell() }
 
        cell.config(with: model[indexPath.section])
        
        if indexPath.section % 2 != 0 {
            cell.setupColor(color: UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1.00))
        } else {
            cell.setupColor(color: UIColor(red: 0.94, green: 0.96, blue: 0.97, alpha: 1.00))
        }
        
        cell.changeColorDelta(value: model[indexPath.section].deltaPrice)
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var sectionSpacing: CGFloat = 1
        if section == 0 {
            sectionSpacing = 0
        }
        return sectionSpacing
    }
    
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
//        if currentIndex != 0 {
//            return .none
//        }
//        return .delete
//    }
//    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete && currentIndex == 0 {
//            guard let model = presenter?.rowModels[indexPath.section] else { return }
//            presenter?.deleteStock(at: model.tickerName)
//            let indexSet = IndexSet(arrayLiteral: indexPath.section)
//            tableView.deleteSections(indexSet, with: .fade)
//        }
//    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.contentView.layer.cornerRadius = 16
            cell.contentView.clipsToBounds = true
            cell.setCellAppearance()
        }
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) {
            cell.setCellAppearance()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter?.openDetailedVC(for: indexPath.section)
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
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        presenter?.openSearchVC()
        return false
    }
}

