//
//  StockService.swift
//  Stocks
//
//  Created by Гурген Хоршикян on 30.01.2023.
//

import Foundation

let apiKey = "cfbo539r01qot24stt10cfbo539r01qot24stt1g"

class StockService {
    
    func fetchStock(for ticker: String, complitions: @escaping (Company) -> Void) {
        let urlString = "https://finnhub.io/api/v1/stock/profile2?symbol=\(ticker)&token=\(apiKey)"
        guard let url = URL(string: urlString) else { return }
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, respone, error in
            guard let data = data else {
                print(error?.localizedDescription)
                return
            }
            
            guard let model = self.parseJson(type: Company.self, data: data) else { return }
            complitions(model)
        }.resume()
    }
    
    func parseJson<T: Codable>(type: T.Type, data: Data) -> T? {
        let decoder = JSONDecoder()
        let model = try? decoder.decode(T.self, from: data)
        return model
    }
    
    func fetchPrice(for ticker: String, complitions: @escaping (Quote) -> Void) {
        let urlString = "https://finnhub.io/api/v1/quote?symbol=\(ticker)&token=\(apiKey)"
        guard let url = URL(string: urlString) else { return }
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(error?.localizedDescription)
                return
            }
            guard let model = self.parseJson(type: Quote.self, data: data) else { return }
            complitions(model)
        }.resume()
    }
}
