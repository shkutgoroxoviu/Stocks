//
//  SearchScreenConfigurator.swift
//  Stocks
//
//  Created by Oleg on 04.04.2023.
//

import Foundation
import UIKit

class SearchScreenConfigurator {
    static func config() -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
        vc.modalPresentationStyle = .fullScreen
        let presenter = SearchPresenter()
        vc.presenter = presenter
        presenter.view = vc
        return vc
    }
}
