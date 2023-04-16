//
//  SearchViewController.swift
//  Stocks
//
//  Created by Oleg on 30.03.2023.
//

import Foundation
import UIKit

protocol SearchViewProtocol: AnyObject {
    func reloadData()
    func openDetailedVC(vc: UIViewController)
}

class SearchViewController: UIViewController, UISearchControllerDelegate, UISearchBarDelegate, SearchViewProtocol {
    var presenter: SearchPresenterProtocol?
    
    var width = 50
    
    private let searchController = UISearchController(searchResultsController: nil)
    @IBOutlet weak var bottomTableViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomCollectionConstraint: NSLayoutConstraint!
    @IBOutlet weak var clearButtonLabel: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    private let tableHeaderView = FilteredsTableViewHeader()
    
    override func viewDidLoad() {
        configUI()
        configSearchBar()
        setTableViewConstraints()
        createGestureRecognizer()
        presenter?.didLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.searchController.searchBar.becomeFirstResponder()
            self.searchController.isActive = true
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func configUI() {
        let headerFooterView = UIView()
        let nibCollectionView = UINib(nibName: NameRowStock.reuseID, bundle: nil)
        collectionView.collectionViewLayout = MyCollectionViewFlowLayout()
        collectionView.register(nibCollectionView, forCellWithReuseIdentifier: NameRowStock.reuseID)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(SearchedHistoryHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        
        let nibTableView = UINib(nibName: PropertyRowStock.reuseID, bundle: nil)
        tableView.register(nibTableView, forCellReuseIdentifier: PropertyRowStock.reuseID)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.sectionHeaderHeight = 1
        tableView.backgroundColor = .white
        tableView.tableHeaderView?.alpha = 0.0
        tableView.showsVerticalScrollIndicator = false
        tableView.isScrollEnabled = false
        tableView.isHidden = true
        tableView.sectionIndexBackgroundColor = .white
        tableView.tableHeaderView = tableHeaderView
        headerFooterView.backgroundColor = .clear
        UITableViewHeaderFooterView.appearance().backgroundView = headerFooterView
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = .white
        
        searchController.searchBar.delegate = self
        searchController.delegate = self
        searchController.isActive = true
        
        tableHeaderView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 15)
        let size = NSString(string: "Show more").size()
        tableHeaderView.delegate = self
        tableHeaderView.setFrameForButton(cgRect: CGRect(x: view.frame.width - size.width - 70, y: -3, width: 100, height: 30))
        
        bottomTableViewConstraint.constant = view.frame.height - 381
    }

    func createGestureRecognizer() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight))
        swipeRight.direction = .right
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        view.addGestureRecognizer(swipeRight)
    }
    
    @objc func dismissKeyboard() {
        self.navigationController?.view.endEditing(true)
    }
    
    @objc func swipeRight(gestureRecognizer: UIPanGestureRecognizer) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func tapOnTicker() {
        tableView.isHidden = false
        collectionView.isHidden = true
        clearButtonLabel.isHidden = true
    }
    
    private func showTableViewOrCollectionView(_ bool: Bool) {
        if bool == true {
            tableView.isHidden = true
            collectionView.isHidden = false
            clearButtonLabel.isHidden = false
        } else {
            tableView.isHidden = false
            collectionView.isHidden = true
            clearButtonLabel.isHidden = true
        }
    }
    
    private func setTableViewConstraints() {
        tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 180).isActive = true
        bottomCollectionConstraint.constant = CGFloat(view.safeAreaLayoutGuide.layoutFrame.height - 296)
    }
    
    private func configSearchBar() {
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont(name: "Montserrat-SemiBold", size: 16) as Any
        ]
        searchController.searchBar.searchBarStyle = .default
        searchController.searchBar.translatesAutoresizingMaskIntoConstraints = false
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
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Find company or ticker", attributes: attributes)
        searchController.searchBar.backgroundColor = .white
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.showsCancelButton = false
        searchController.searchBar.clearsContextBeforeDrawing = true
        
        navigationItem.titleView?.backgroundColor = .white
        navigationItem.searchController?.searchBar.tintColor = .white
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.barStyle = UIBarStyle.default
        navigationController?.navigationBar.tintColor = UIColor.black
    }
    
    func reloadData() {
        if searchController.searchBar.text?.isEmpty == true {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        } else {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func openDetailedVC(vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func clearButton(_ sender: Any) {
        presenter?.clearSearchHistory()
    }
    
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
}

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let presenter = presenter else { return 0 }
        return presenter.searchHistory.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NameRowStock.reuseID, for: indexPath) as! NameRowStock
        guard let model = presenter?.searchHistory[indexPath.row] else { return cell }
        cell.config(with: model)
        cell.layoutIfNeeded()

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let presenter = presenter else { return CGSize(width: 0, height: 0) }
        guard presenter.searchHistory.isEmpty != true else { return CGSize(width: 0, height: 0) }
        let size = NSString(string: presenter.searchHistory[indexPath.row]).size()
        return CGSize(width: width + Int(size.width), height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) as! SearchedHistoryHeader
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 10, height: 250)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let ticker = presenter?.searchHistory[indexPath.row] else { return }
        presenter?.filterContentForSearchText(ticker)
        searchController.searchBar.text = ticker
        tapOnTicker()
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PropertyRowStock.reuseID, for: indexPath) as! PropertyRowStock
        
        guard let model = self.presenter?.filteredRows[indexPath.section] else { return cell }
        
        cell.config(with: model)
        
        if indexPath.section % 2 != 0 {
            cell.setupColor(color: UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1.00))
        } else {
            cell.setupColor(color: UIColor(red: 0.94, green: 0.96, blue: 0.97, alpha: 1.00))
        }
        cell.changeColorDelta(value: model.deltaPrice)
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if presenter?.filteredRows.count == 0 {
            tableHeaderView.hideIfTableEmpty(true)
        } else {
            tableHeaderView.hideIfTableEmpty(false)
        }
        return presenter?.filteredRows.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let sectionSpacing: CGFloat = 1
        return sectionSpacing
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard var presenter = presenter else { return }
        presenter.detectRepeated(text: presenter.filteredRows[indexPath.section].tickerName)
        presenter.openDetailedVC(for: indexPath.section)
    }
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        presenter?.filterContentForSearchText(text)
    }
}

extension SearchViewController: TapFavoriteProtocol {
    func didTap(bool: Bool, name: String) {
        presenter?.changeIsFavorite(bool: bool, ticker: name)
    }
}

extension SearchViewController {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.showTableViewOrCollectionView(searchText.isEmpty)
        if searchText.isEmpty {
            UIView.animate(withDuration: 0.3) {
                self.bottomTableViewConstraint.constant = self.view.frame.height - 381
                self.view.layoutIfNeeded()
                self.tableView.isScrollEnabled = false
                self.tableHeaderView.setNameForButton()
            }
        }
    }
}

extension SearchViewController: TapShowButton {
    func didTap(bool: Bool) {
        if bool == true {
            UIView.animate(withDuration: 0.3) {
                self.bottomTableViewConstraint.constant = 0
                self.view.layoutIfNeeded()
                self.tableView.isScrollEnabled = true
                self.navigationController?.view.endEditing(true)
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.bottomTableViewConstraint.constant = self.view.frame.height - 381
                self.view.layoutIfNeeded()
                self.tableView.isScrollEnabled = false
            }
        }
    }
}

