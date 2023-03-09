//
//  Stock.swift
//  Stocks
//
//  Created by Гурген Хоршикян on 30.01.2023.
//

import Foundation
import UIKit

struct Stock: Codable {
    var companyProfile: Company
    var quote: Quote
}

