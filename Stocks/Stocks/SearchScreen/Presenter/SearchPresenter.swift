//
//  SearchPresenter.swift
//  Stocks
//
//  Created by Oleg on 31.03.2023.
//

import Foundation

protocol SearchPresenterProtocol {
    func filterContentForSearchText(_ searchText: String)
    
    func changeIsFavorite(bool: Bool, ticker: String)
    
    func didLoad()
    
    func loadSearchTickers()
    
    func clearSearchHistory()
    
    func openDetailedVC(for index: Int)
    
    func detectRepeated(text: String)
    
    var filteredRows: [PropertyRowStockModel] { get set }
    
    var rowModels: [PropertyRowStockModel] { get set }
    
    var searchHistory: [String] { get set }
}


class SearchPresenter: SearchPresenterProtocol {
    weak var view: SearchViewProtocol?
    
    private var networkService = StockService()
    private var coreDataService = CoreDataService()
    
    private var searchedTickers: [String] {
        return UserDefaults.searchedTickers
    }
    private var tickers: [String] {
        return UserDefaults.tickers
    }
    
    var filteredRows: [PropertyRowStockModel] = []
    var rowModels: [PropertyRowStockModel] = []
    var searchHistory: [String] = []
    
    private var dispatchGroup = DispatchGroup()
    
    private var text: String?
   
    func didLoad() {
        loadAllTickers()
        loadSearchTickers()
    }
    
    func filterContentForSearchText(_ searchText: String) {
        self.text = searchText
        didTapOnSearch()
        self.networkService.fetchStock(for: searchText.lowercased()) { [weak self]  stock in
            let model = PropertyRowStockModel(
                tickerName: stock.companyProfile.ticker,
                name: stock.companyProfile.name,
                image: stock.companyProfile.logo,
                deltaPrice: stock.quote.d,
                currentPrice: stock.quote.c,
                deltaProcent: stock.quote.dp,
                isFavorite: false
            )
            guard let self = self else { return }
            self.deleteRepeated(text: searchText, stock: stock, model: model)
            self.view?.reloadData()
        }
        self.view?.reloadData()
    }
    
    private func loadAllTickers() {
        for ticker in tickers {
            networkService.fetchStock(for: ticker) { [weak self] stock  in
                guard let self = self else { return }
                self.coreDataService.update(with: stock)
            }
        }
        update()
    }
    
    func loadSearchTickers() {
        for ticker in searchedTickers {
            searchHistory.append(ticker)
        }
    }
    
    private func update() {
        guard let dataModels = self.coreDataService.fetchStock() else { return }
        rowModels = dataModels.compactMap({ model in
            return PropertyRowStockModel(
                tickerName: model.ticker,
                name: model.name,
                image: model.logo,
                deltaPrice: model.d,
                currentPrice: model.c,
                deltaProcent: model.dp,
                isFavorite: model.isFavorite
            )
        })
        view?.reloadData()
    }
    
    private func addTickerInHistory(bool: Bool, text: String) {
        if bool == false && searchHistory.contains(text) {
            return
        } else if bool == true && !searchHistory.contains(text)  {
            UserDefaults.searchedTickers.append(text)
            self.searchHistory.append(text)
        }
    }
    
    func detectRepeated(text: String) {
        if searchHistory.contains(text) {
            return
        } else {
            UserDefaults.searchedTickers.append(text)
            self.searchHistory.append(text)
        }
    }
    
    func changeIsFavorite(bool: Bool, ticker: String) {
        coreDataService.changeToFavorite(tickerString: ticker, isFavorite: bool)
        addTickerInHistory(bool: bool, text: ticker)
        didTapOnSearch()
    }
    
    func openDetailedVC(for index: Int) {
        let name = filteredRows[index].tickerName
        guard let model = coreDataService.fetchOneElement(name: name) else { return }
        let vc = DetailedScreenConfigurator.config(with: model)
        view?.openDetailedVC(vc: vc)
    }
    
    private func deleteRepeated(text: String, stock: Stock, model: PropertyRowStockModel) {
        if self.rowModels.contains(where: { $0.tickerName.lowercased() == text.lowercased() }) {
            return
        } else {
            self.addStock(at: stock)
            self.filteredRows.append(model)
        }
    }
    
    private func didTapOnSearch() {
        update()
        filteredRows = rowModels.filter { model -> Bool in
            return model.tickerName.lowercased().contains(self.text?.lowercased() ?? "")
        }
        view?.reloadData()
    }
    
    private func addStock(at stock: Stock) {
        coreDataService.addStock(stock: stock)
        UserDefaults.tickers.append(stock.companyProfile.ticker)
        update()
    }
    
    func clearSearchHistory() {
        searchHistory = []
        UserDefaults.searchedTickers.removeAll()
        loadSearchTickers()
        view?.reloadData()
    }
}
