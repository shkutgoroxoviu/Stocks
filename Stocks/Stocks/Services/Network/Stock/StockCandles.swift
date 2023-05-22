//
//  QuotePerInterval.swift
//  Stocks
//
//  Created by Oleg on 19.04.2023.
//

import Foundation

struct StockCandles: Codable {
    var c: [Double] // list of close prices
    var t: [Double] // list of timestamp 
}
