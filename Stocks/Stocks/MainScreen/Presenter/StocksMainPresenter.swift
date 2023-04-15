//
//  StockMainPresenter.swift
//  Stocks
//
//  Created by Гурген Хоршикян on 28.01.2023.
//

import Foundation

protocol StocksMainPresenterProtocol {
//    var filteredRows: [PropertyRowStockModel] { get set }
    
    var rowModels: [PropertyRowStockModel] { get set }
    
    var favoriteModels: [PropertyRowStockModel] { get set }
    
    var currentList: [PropertyRowStockModel] { get set }
    
    func openSearchVC()
    
    func openDetailedVC(for index: Int)
    
    func didLoad()
    
    func deleteStock(at ticker: String)
    
    func changeMenu(index: Int)
    
    func changeIsFavorite(bool: Bool, ticker: String)
    
    func refreshFavoriteMenu()
    
    func didTapFavoriteMenuItem()
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
    
    var currentIndex: Int = 0
    var text: String?
    
    var dispatchGroup = DispatchGroup()
    
    func openSearchVC() {
        let vc = SearchScreenConfigurator.config()
        view?.openSearchVC(vc: vc)
    }
    
    func openDetailedVC(for index: Int) {
        var name = ""
        if currentIndex == 0 {
            name = rowModels[index].tickerName
        } else {
            name = favoriteModels[index].tickerName
        }
        guard let model = coreDataService.fetchOneElement(name: name) else { return }
        let vc = DetailedScreenConfigurator.config(with: model)
        view?.openDetailedVC(vc: vc)
    }
    
    func didLoad() {
        loadAllTickers()
    }
    
    func refreshFavoriteMenu() {
        loadAllTickers()
        favoriteModels = []
        didTapFavoriteMenuItem()
    }
    
    func loadAllTickers() {
        for ticker in tickers {
            networkService.fetchStock(for: ticker) { [weak self] stock  in
                guard let self = self else { return }
                self.coreDataService.update(with: stock)
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
        currentList = favoriteModels
        view?.reloadData()
    }
    
    func detectingCurrentIndex(index: Int) {
        if index == 0 {
            self.update()
        } else {
            favoriteModels = []
            didTapFavoriteMenuItem()
        }
    }
    
    func changeIsFavorite(bool: Bool, ticker: String) {
        coreDataService.changeToFavorite(tickerString: ticker, isFavorite: bool)
        detectingCurrentIndex(index: currentIndex)
    }
    
    func changeMenu(index: Int) {
        switch index {
        case 0:
            loadAllTickers()
            favoriteModels = []
            update()
            currentIndex = index
        case 1:
            loadAllTickers()
            favoriteModels = []
            didTapFavoriteMenuItem()
            currentIndex = index
        default:
            return
        }
    }
}
