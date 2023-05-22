//
//  DetailedScreenConfigurator.swift
//  Stocks
//
//  Created by Oleg on 09.04.2023.
//

import Foundation
import UIKit

class DetailedScreenConfigurator {
    static func config(with model: StockCoreDataModel) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DetailedViewController") as! DetailedViewController
        let presenter = DetailedPresenter(model: model)
        vc.presenter = presenter 
        presenter.view = vc
        return vc
    }
}
