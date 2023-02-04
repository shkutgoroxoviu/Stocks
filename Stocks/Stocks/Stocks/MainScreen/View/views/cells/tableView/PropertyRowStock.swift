//
//  propertyRow.swift
//  Stocks
//
//  Created by Гурген Хоршикян on 21.01.2023.
//

import UIKit
import Foundation

class PropertyRowStock: UITableViewCell {

    static var reuseID = "PropertyRowStock"
    
    let favoriteButton = UIButton(type: .custom)
    
    @IBOutlet weak var deltaPrice: UILabel!
    @IBOutlet weak var currentPrice: UILabel!
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var stockImage: UIImageView!
    @IBOutlet weak var stockTicker: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configUI()
    }
    
    func configUI() {
        stockImage.layer.cornerRadius = 10

        favoriteButton.frame = CGRect(x: 0, y: 0, width: stockTicker.frame.width, height: stockTicker.frame.height)
        favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        favoriteButton.tintColor = .systemYellow
        favoriteButton.addTarget(self, action: #selector(favoriteButtonPressed), for: .touchUpInside)
        deltaPrice.textAlignment = .right
        currentPrice.textAlignment = .right
        companyName.textAlignment = .center
        stockTicker.textAlignment = .center
        
        accessoryView = favoriteButton
    }
    
//    private func configLayout() {
//        self.addSubview(favoriteButton)
//        NSLayoutConstraint.activate([
//            favoriteButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
//            favoriteButton.heightAnchor.constraint(equalToConstant: 50),
//            favoriteButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 32),
//                // You can trust some attributes, like the width, to autolayout if you want
//            ])
//        }
    
    @objc private func favoriteButtonPressed(_ sender: UIButton) {
        sender.tintColor = .systemYellow
    }
   

    func configName(with model: PropertyRowStockModelName) {
        companyName.text = model.name
        stockTicker.text = model.tickerName
//        let url = URL(string: model.image)
//        let data = try? Data(contentsOf: url!)
//        stockImage.image = UIImage(data: data!)
//
        let url = URL(string: model.image)

        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url!)
            DispatchQueue.main.async {
                self.stockImage.image = UIImage(data: data!)
            }
        }
    }
}



