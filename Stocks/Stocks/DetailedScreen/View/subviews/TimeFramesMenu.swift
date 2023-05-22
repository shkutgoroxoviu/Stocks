//
//  TimeFramesMenu.swift
//  Stocks
//
//  Created by Oleg on 20.04.2023.
//

import Foundation
import UIKit

public protocol TimeFrameDelegate {
    func changeFrame(index: Int)
}

open class TimeFramesMenu: UIStackView {
    public var delegate: TimeFrameDelegate?
    
    private var currentPosition: Int = 0
    var isBlocked: Bool = false
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        axis = .horizontal
        alignment = .fill
        spacing = 10
        distribution = .fillEqually
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func configure(with titles: [String]) {
        arrangedSubviews.forEach {
            removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        for (index, title) in titles.enumerated() {
            let button = createButton(title: title, index: index)
            addArrangedSubview(button)
        }
        updateButtons()
    }
    
    private func createButton(title: String, index: Int) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)

        button.frame = CGRect(x: 0, y: 0, width: 110, height: 50)
        button.titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 12)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 10
        button.tag = index
        button.addTarget(self, action: #selector(clickMenuTitle), for: .touchUpInside)
        return button
    }
    
    private func updateButtons() {
        arrangedSubviews.forEach({ button in
            if let button = button as? UIButton {
                if button.tag == currentPosition {
                    button.setTitleColor(.white, for: .normal)
                    button.backgroundColor = .black
                } else {
                    button.setTitleColor(.black, for: .normal)
                    button.backgroundColor = UIColor(red: 0.94, green: 0.96, blue: 0.97, alpha: 1.00)
                }
            }
        })
    }
    
    @objc func clickMenuTitle(_ sender: UIButton) {
        guard !isBlocked else { return }
        currentPosition = sender.tag
        updateButtons()
        delegate?.changeFrame(index: sender.tag)
    }
    
    func forceUpdatePosition(_ index: Int) {
        currentPosition = index
        updateButtons()
    }
}

