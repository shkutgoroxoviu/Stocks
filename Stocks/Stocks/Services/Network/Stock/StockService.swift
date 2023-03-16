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
                
                URLSession.shared.dataTask(with: requestQuote) { data, response, error in
                    guard let data = data else {
                        print(error?.localizedDescription)
                        return
                    }
                    guard let quote = self.parseJson(type: Quote.self, data: data) else { return }
                    
                    let stock = Stock(companyProfile: company, quote: quote)
                    complitions(stock)
                }.resume()
            }.resume()
    }
    
    func parseJson<T: Codable>(type: T.Type, data: Data) -> T? {
        let decoder = JSONDecoder()
        let model = try? decoder.decode(T.self, from: data)
        return model
    }
}
