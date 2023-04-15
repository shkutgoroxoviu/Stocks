//
//  FilteredsTableViewHeader.swift
//  Stocks
//
//  Created by Oleg on 07.04.2023.
//

import Foundation
import UIKit

protocol TapShowButton {
    func didTap(bool: Bool)
}

class FilteredsTableViewHeader: UIView {
    static var reuseId = "FilteredsTableViewHeader"
    
    var delegate: TapShowButton?
    
    private var titleLabel = UILabel()
    private var showMoreButton = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setFrameForButton(cgRect: CGRect) {
        showMoreButton.frame = cgRect
    }
    
    func setNameForButton() {
        showMoreButton.setTitle("Show More", for: .normal)
    }
    
    func hideIfTableEmpty(_ bool: Bool) {
        if bool == true {
            self.isHidden = true
        } else {
            self.isHidden = false
        }
    }

    func configUI() {
        titleLabel.frame = CGRect(x: 5, y: -30, width: 300, height: 80)
        titleLabel.textColor = .black
        titleLabel.text = "Stocks"
        titleLabel.font = UIFont(name: "Montserrat-Bold", size: 22)
        
        showMoreButton.setTitleColor(.black, for: .normal)
        showMoreButton.setTitle("Show More", for: .normal)
        showMoreButton.titleLabel?.textAlignment = .right
        showMoreButton.titleLabel?.font = UIFont(name: "Montserrat-SemiBold", size: 16)
        showMoreButton.addTarget(self, action: #selector(showMoreButtonAction), for: .touchUpInside)
        showMoreButton.translatesAutoresizingMaskIntoConstraints = true
        
        addSubview(showMoreButton)
        addSubview(titleLabel)
    }
    
    @objc func showMoreButtonAction() {
        if showMoreButton.titleLabel?.text == "Show More" {
            self.showMoreButton.setTitle("Hide", for: .normal)
            self.showMoreButton.titleLabel?.textAlignment = .right
            self.showMoreButton.titleLabel?.font = UIFont(name: "Montserrat-SemiBold", size: 16)
            delegate?.didTap(bool: true)
        } else {
            self.showMoreButton.setTitle("Show More", for: .normal)
            self.showMoreButton.titleLabel?.font = UIFont(name: "Montserrat-SemiBold", size: 16)
            delegate?.didTap(bool: false)
        }
    }
}
