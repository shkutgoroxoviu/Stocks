//
//  StockMainPresenter.swift
//  Stocks
//
//  Created by Гурген Хоршикян on 28.01.2023.
//

import Foundation

protocol StocksMainPresenterProtocol {
    var filteredRows: [PropertyRowStockModelName] { get }
    
    var rowModels: [PropertyRowStockModelName] { get set }
    
    func filterContentForSearchText(_ searchText: String)
    
    func didLoad()
    
    func loadStock(ticker: String)
}

class StocksMainPresenter: StocksMainPresenterProtocol {
    weak var view: StocksMainViewProtocol?
    
    private var networkService = StockService()
    private var coreDataService = CoreDataService()
    
    private var tickers: [String] {
        return UserDefaults.tickers
    }
    
    var filteredRows: [PropertyRowStockModelName] = []
    var rowModels: [PropertyRowStockModelName] = []
    
    var dispatchGroup = DispatchGroup()
    
    func filterContentForSearchText(_ searchText: String) {
//        filteredRows = rowModels.filter { model -> Bool in
//            return model.tickerName.lowercased().contains(searchText.lowercased())
//        }
//        view?.reloadData()
    }
    
    func didLoad() {
        loadAllTickers()
    }
    
    func loadAllTickers() {
        for ticker in tickers {
            
            networkService.fetchStock(for: ticker) { [weak self] stock in
                
                self?.coreDataService.update(with: stock)
            }
        }
       
        update()
    }
    
    func update() {
        guard let dataModels = self.coreDataService.fetchStock() else { return }
        rowModels = dataModels.compactMap({ model in
            return PropertyRowStockModelName(
                tickerName: model.ticker,
                name: model.name,
                image: model.logo)
        })
        
        view?.reloadData()
    }
    
    func loadStock(ticker: String) {
        
    }
    
    func addStock(at stock: Company) {
        coreDataService.addStock(stock: stock)
        UserDefaults.tickers.append(stock.ticker)
        update()
    }
}
