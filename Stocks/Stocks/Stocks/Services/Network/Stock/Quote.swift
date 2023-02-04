//
//  Quote.swift
//  Stocks
//
//  Created by Гурген Хоршикян on 30.01.2023.
//

import Foundation

struct Quote: Codable {
    var c: Double // current price
    var d: Double // change
    var dp: Double // percent change
    var l: Double
    var o: Double
    var pc: Double
    var t: Double
}
