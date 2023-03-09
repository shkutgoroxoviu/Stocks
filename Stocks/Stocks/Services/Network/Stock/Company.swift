//
//  CompanyProfile.swift
//  Stocks
//
//  Created by Гурген Хоршикян on 30.01.2023.
//

import Foundation

struct Company: Codable {
    let country, currency, exchange, finnhubIndustry: String
    let ipo: String
    let logo: String
    let marketCapitalization: Double
    let name: String
    let phone: String
    let shareOutstanding: Double
    let ticker: String
    let weburl: String
}
