//
//  DetailedPresenter.swift
//  Stocks
//
//  Created by Oleg on 09.04.2023.
//
import Charts
import Foundation

protocol DetailedPresenterProtocol {
    func viewDidLoad()
    
    func changeIsFavorite(bool: Bool, ticker: String)
    
    func changeMenu(index: Int)
    
    func loadDataForChart(ticker: String, timeframe: Any)
    
    var model: StockCoreDataModel { get set }
    
    var candlesClosePrice: [Double] { get set }
    
    var candlesData: [Double] { get set }
    
    var dataEntries: [ChartDataEntry] { get set }
}

class DetailedPresenter: DetailedPresenterProtocol {
    weak var view: DetailedViewProtocol?
    
    private var coreDataService = CoreDataService()
    private var networkService = StockService()
    
    var candlesClosePrice: [Double] = []
    var candlesData: [Double] = []
    var model: StockCoreDataModel
    var dataEntries: [ChartDataEntry] = []
    
    var timeFrame: String = "D"
    
    init(model: StockCoreDataModel) {
        self.model = model
    }
    
    func viewDidLoad() {
        view?.config(model: model)
        loadDataForChart(ticker: model.ticker, timeframe: timeFrame)
    }
    
    func loadDataForChart(ticker: String, timeframe: Any) {
        self.networkService.fetchStockCandles(ticker: ticker, timeframe: timeframe) { stockCandles in
            self.candlesClosePrice = stockCandles.c
            self.candlesData = stockCandles.t
            DispatchQueue.main.async {
                for i in 0..<stockCandles.c.count {
                    self.dataEntries.append(ChartDataEntry(x: Double(i), y: stockCandles.c[i]))
                }
                self.view?.configChart()
                self.view?.stopSpinner()
            }
        }
    }
    
    func changeIsFavorite(bool: Bool, ticker: String) {
        coreDataService.changeToFavorite(tickerString: ticker, isFavorite: bool)
    }
    
    func changeMenu(index: Int) {
        switch index {
        case 0:
            timeFrame = "5"
            dataEntries = []
            view?.startSpinner()
            view?.deleteThePreviousWindow()
            loadDataForChart(ticker: model.ticker, timeframe: timeFrame)
            view?.reloadData()
        case 1:
            timeFrame = "15"
            dataEntries = []
            view?.startSpinner()
            view?.deleteThePreviousWindow()
            loadDataForChart(ticker: model.ticker, timeframe: timeFrame)
            view?.reloadData()
        case 2:
            timeFrame = "30"
            dataEntries = []
            view?.startSpinner()
            view?.deleteThePreviousWindow()
            loadDataForChart(ticker: model.ticker, timeframe: timeFrame)
            view?.reloadData()
        case 3:
            timeFrame = "60"
            dataEntries = []
            view?.startSpinner()
            view?.deleteThePreviousWindow()
            loadDataForChart(ticker: model.ticker, timeframe: timeFrame)
            view?.reloadData()
        case 4:
            timeFrame = "D"
            dataEntries = []
            view?.startSpinner()
            view?.deleteThePreviousWindow()
            loadDataForChart(ticker: model.ticker, timeframe: timeFrame)
            view?.reloadData()
        case 5:
            timeFrame = "W"
            dataEntries = []
            view?.startSpinner()
            view?.deleteThePreviousWindow()
            loadDataForChart(ticker: model.ticker, timeframe: timeFrame)
            view?.reloadData()
        case 6:
            timeFrame = "M"
            dataEntries = []
            view?.startSpinner()
            view?.deleteThePreviousWindow()
            loadDataForChart(ticker: model.ticker, timeframe: timeFrame)
            view?.reloadData()
        default:
            return
        }
    }

}
