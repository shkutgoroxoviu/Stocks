//
//  StockMainPresenter.swift
//  Stocks
//
//  Created by Гурген Хоршикян on 28.01.2023.
//

import Foundation

protocol StocksMainPresenterProtocol {
    var filteredRows: [PropertyRowStockModel] { get }
    
    var rowModels: [PropertyRowStockModel] { get set }
    
    var favoriteModels: [PropertyRowStockModel] { get set }
    
    var currentList: [PropertyRowStockModel] { get set }
    
    func filterContentForSearchText(_ searchText: String)
    
    func didLoad()
    
    func deleteStock(at ticker: String)
    
    func changeMenu(index: Int)
    
    func changeIsFavorite(bool: Bool, ticker: String)
}

class StocksMainPresenter: StocksMainPresenterProtocol {
    weak var view: StocksMainViewProtocol?
    
    private var networkService = StockService()
    private var coreDataService = CoreDataService()
    
    private var tickers: [String] {
        return UserDefaults.tickers
    }
    
    var filteredRows: [PropertyRowStockModel] = []
    var rowModels: [PropertyRowStockModel] = []
    var favoriteModels: [PropertyRowStockModel] = []
    var currentList: [PropertyRowStockModel] = []
    
    var dispatchGroup = DispatchGroup()
    
    func filterContentForSearchText(_ searchText: String) {
        filteredRows = rowModels.filter { model -> Bool in
            return model.tickerName.lowercased().contains(searchText.lowercased())
        }
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
        view?.reloadData()
    }
    
    func deleteRepeated(text: String, stock: Stock, model: PropertyRowStockModel ) {
        if self.rowModels.contains(where: { $0.tickerName.lowercased() == text.lowercased() }) {
            return
        } else {
            self.addStock(at: stock)
            self.filteredRows.append(model)
        }
    }
    
    func didLoad() {
        loadAllTickers()
    }
    
    func loadAllTickers() {
        for ticker in tickers {
            networkService.fetchStock(for: ticker) { [weak self] stock  in
                self!.coreDataService.update(with: stock)
            }
        }
        update()
    }
    
    func update() {
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
        currentList = rowModels
        view?.reloadData()
    }
    
    func addStock(at stock: Stock) {
        coreDataService.addStock(stock: stock)
        UserDefaults.tickers.append(stock.companyProfile.ticker)
        update()
    }
    
    func deleteStock(at ticker: String) {
        coreDataService.deleteStock(ticker)
        UserDefaults.tickers.removeAll { $0 == ticker }
        update()
    }
    
    func didTapFavoriteMenuItem() {
        for model in currentList {
            let ticker = model.tickerName
            if coreDataService.checkToFavorite(from: ticker) {
                favoriteModels.append(model)
            }
        }
    }
    
    func changeIsFavorite(bool: Bool, ticker: String) {
        coreDataService.changeToFavorite(tickerString: ticker, isFavorite: bool)
    }
    
    func changeMenu(index: Int) {
        switch index {
        case 0:
            favoriteModels = []
            update()
        case 1:
            didTapFavoriteMenuItem()
            currentList = favoriteModels
            view?.reloadData()
        default:
            return
        }
    }
}
