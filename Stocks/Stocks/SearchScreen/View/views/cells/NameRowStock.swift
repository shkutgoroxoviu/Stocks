//
//  NameRowStock.swift
//  Stocks
//
//  Created by Oleg on 31.03.2023.
//

import Foundation
import UIKit

protocol TapTicker {
    func didTap(name: String)
}

class NameRowStock: UICollectionViewCell {
    
    static var reuseID = "NameRowStock"
    var delegate: TapTicker?
    var layout: MyCollectionViewFlowLayout?
    
    @IBOutlet weak var ticker: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configUI()
    }
    
    func configUI() {
        self.layer.cornerRadius = 20
        self.backgroundColor = UIColor(red: 0.94, green: 0.96, blue: 0.97, alpha: 1.00)
        self.layer.masksToBounds = true
        ticker.textAlignment = .center
    }
    
    func config(with model: String) {
        ticker.text = model
    }
    
    func didSelectCell() {
        delegate?.didTap(name: ticker.text ?? "")
    }
}
