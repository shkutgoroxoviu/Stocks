//
//  propertyRow.swift
//  Stocks
//
//  Created by Гурген Хоршикян on 21.01.2023.
//

import UIKit
import SDWebImage
import SVGKit

protocol TapFavoriteProtocol {
    func didTap(bool: Bool, name: String)
}

class PropertyRowStock: UITableViewCell {
    static var reuseID = "PropertyRowStock"
    
    var delegate: TapFavoriteProtocol?
    
    @IBOutlet weak private var deltaProcent: UILabel!
    @IBOutlet weak private var favoriteButton: UIButton!
    @IBOutlet weak private var deltaPrice: UILabel!
    @IBOutlet weak private var currentPrice: UILabel!
    @IBOutlet weak private var companyName: UILabel!
    @IBOutlet weak private var stockImage: CustomImageView!
    @IBOutlet weak private var stockTicker: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configUI()
    }
    
    private func configUI() {
        stockImage.layer.cornerRadius = 12
        deltaPrice.textAlignment = .right
        currentPrice.textAlignment = .right
        companyName.textAlignment = .left
        stockTicker.textAlignment = .left
        var configuration = UIButton.Configuration.filled()
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 40, leading: 40, bottom: 40, trailing: 40)
        favoriteButton.configuration = configuration
        favoriteButton.configuration?.baseBackgroundColor = .clear
        self.layer.cornerRadius = 16
        self.contentView.layer.cornerRadius = 16
        self.layer.masksToBounds = true
        self.selectionStyle = .none
    }

    func setupColor(color: UIColor) {
        self.backgroundColor = color
    }
    
    func changeColorDelta(value: Double) {
        if value < 0 {
            deltaProcent.textColor = UIColor(red: 0.70, green: 0.14, blue: 0.14, alpha: 1.00)
            deltaPrice.textColor = UIColor(red: 0.70, green: 0.14, blue: 0.14, alpha: 1.00)
        } else {
            deltaProcent.textColor = UIColor(red: 0.14, green: 0.70, blue: 0.14, alpha: 1.00)
            deltaPrice.textColor = UIColor(red: 0.14, green: 0.70, blue: 0.14, alpha: 1.00)
        }
    }
    
    func config(with model: PropertyRowStockModel) {
        companyName.text = model.name
        stockTicker.text = model.tickerName
        stockImage.load(urlString: model.image)
        deltaPrice.text = "\(model.deltaPrice)$"
        currentPrice.text = "\(model.currentPrice)$"
        deltaProcent.text = "(\(round(model.deltaProcent * 100)/100)%)"
        buttonSelected(bool: model.isFavorite)
    }
    
    func buttonSelected(bool: Bool) {
        bool ? favoriteButton.setImage(UIImage(named: "selected"), for: .normal) : favoriteButton.setImage(UIImage(named: "Star 1"), for: .normal)
    }
    
    @IBAction private func favoriteButtonAction(_ sender: UIButton) {
        if favoriteButton.imageView?.image == UIImage(named: "selected")  {
            buttonSelected(bool: false)
            favoriteButton.isSelected = !favoriteButton.isSelected
            
            delegate?.didTap(bool: false, name: stockTicker.text ?? "")
        } else if favoriteButton.imageView?.image == UIImage(named: "Star 1") {
            buttonSelected(bool: true)
            favoriteButton.isSelected = !favoriteButton.isSelected
            
            delegate?.didTap(bool: true, name: stockTicker.text ?? "")
        }
    }
}

extension UITableViewCell {
    func setCellAppearance() {
        self.layer.cornerRadius = 16
        self.clipsToBounds = true
    }
}

