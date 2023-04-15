//
//  DetailedPresenter.swift
//  Stocks
//
//  Created by Oleg on 09.04.2023.
//

import Foundation

protocol DetailedPresenterProtocol {
    func viewDidLoad()
    
    func changeIsFavorite(bool: Bool, ticker: String)
}

class DetailedPresenter: DetailedPresenterProtocol {
    weak var view: DetailedViewProtocol?
    
    private var coreDataService = CoreDataService()
    
    let model: StockCoreDataModel
    
    init(model: StockCoreDataModel) {
        self.model = model
    }
    
    func viewDidLoad() {
        view?.config(model: model)
    }
    
    func changeIsFavorite(bool: Bool, ticker: String) {
        coreDataService.changeToFavorite(tickerString: ticker, isFavorite: bool)
    }
}
