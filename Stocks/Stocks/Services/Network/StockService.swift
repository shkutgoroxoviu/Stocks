//
//  StockService.swift
//  Stocks
//
//  Created by Гурген Хоршикян on 30.01.2023.
//

import Foundation

let apiKey = "cfbo539r01qot24stt10cfbo539r01qot24stt1g"
let group = DispatchGroup()

class StockService {
    var timeframe = "D"
    
    func fetchStock(for ticker: String, complitions: @escaping (Stock) -> Void) {
        guard let urlCompany = URL(string: "https://finnhub.io/api/v1/stock/profile2?symbol=\(ticker)&token=\(apiKey)") else { return }
        guard let urlQuote = URL(string:"https://finnhub.io/api/v1/quote?symbol=\(ticker)&token=\(apiKey)") else { return }
        
        let requestCompany = URLRequest(url: urlCompany)
        let requestQuote = URLRequest(url: urlQuote)
        
        URLSession.shared.dataTask(with: requestCompany) { data, respone, error in
            guard let data = data else {
                print(error?.localizedDescription)
                return
            }
            guard let company = self.parseJson(type: Company.self, data: data) else { return }
            
            DispatchQueue.main.async {
                URLSession.shared.dataTask(with: requestQuote) { data, response, error in
                    guard let data = data else {
                        print(error?.localizedDescription)
                        return
                    }
                    guard let quote = self.parseJson(type: Quote.self, data: data) else { return }
                    
                    let stock = Stock(companyProfile: company, quote: quote)
                    complitions(stock)
                }.resume()
            }
        }.resume()
    }
    
    func fetchCompany(for ticker: String, complitions: @escaping (Company) -> Void) {
        guard let urlCompany = URL(string: "https://finnhub.io/api/v1/stock/profile2?symbol=\(ticker)&token=\(apiKey)") else { return }
        
        let requestCompany = URLRequest(url: urlCompany)
        
        DispatchQueue.main.async {
            URLSession.shared.dataTask(with: requestCompany) { data, respone, error in
                guard let data = data else {
                    print(error?.localizedDescription as Any)
                    return
                }
                guard self.parseJson(type: Company.self, data: data) != nil else { return }
            }.resume()
        }
    }
    
    func fetchQuote(for ticker: String, complitions: @escaping (Quote) -> Void) {
        guard let urlQuote = URL(string: "https://finnhub.io/api/v1/quote?symbol=\(ticker)&token=\(apiKey)") else { return }
        
        let requestQuote = URLRequest(url: urlQuote)
        
        DispatchQueue.main.async {
            URLSession.shared.dataTask(with: requestQuote) { data, response, error in
                guard let data = data else {
                    print(error?.localizedDescription as Any)
                    return
                }
                guard let quote = self.parseJson(type: Quote.self, data: data) else { return }
                complitions(quote)
            }.resume()
        }
    }
    
    func fetchStockCandles(ticker: String, timeframe: Any, complitions: @escaping (StockCandles) -> Void) {
        var fromUnixDate = "1674565200"
        
        if timeframe as! String == "5" {
            fromUnixDate = "1679662800"
        } else if timeframe as! String == "M" || timeframe as! String == "W" {
            fromUnixDate = "1650805200"
        }
        
        guard let urlStocksCandles = URL(string: "https://finnhub.io/api/v1/stock/candle?symbol=\(ticker)&resolution=\(timeframe)&from=\(fromUnixDate)&to=1682341200&token=\(apiKey)") else { return }
        
        let requestStocksCandles = URLRequest(url: urlStocksCandles)
        
        DispatchQueue.main.async {
            URLSession.shared.dataTask(with: requestStocksCandles) { data, response, error in
                guard let data = data else {
                    print(error?.localizedDescription as Any)
                    return
                }
                guard let stockCandles = self.parseJson(type: StockCandles.self, data: data) else { return }
                complitions(stockCandles)
            }.resume()
        }
    }
    
    func parseJson<T: Codable>(type: T.Type, data: Data) -> T? {
        let decoder = JSONDecoder()
        let model = try? decoder.decode(T.self, from: data)
        return model
    }
}
