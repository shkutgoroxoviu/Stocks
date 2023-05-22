//
//  SearchedHistoryHeader.swift
//  Stocks
//
//  Created by Oleg on 05.04.2023.
//

import Foundation
import UIKit

class SearchedHistoryHeader: UICollectionReusableView {
    
    private var titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configUI()
    }

    func configUI() {
        titleLabel.frame = CGRect(x: 20, y: -30, width: 300, height: 80)
        titleLabel.textColor = .black
        titleLabel.text = "You’ve searched for this"
        titleLabel.font = UIFont(name: "Montserrat-Bold", size: 18)
        addSubview(titleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
