//
//  MainScreenConfigurator.swift
//  Stocks
//
//  Created by Гурген Хоршикян on 28.01.2023.
//

import Foundation
import UIKit


class MainScreenConfigurator {
    static func config() -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MainViewController") as! StocksMainViewController
        let presenter = StocksMainPresenter()
        vc.presenter = presenter
        presenter.view = vc
        
        return vc
    }
}
