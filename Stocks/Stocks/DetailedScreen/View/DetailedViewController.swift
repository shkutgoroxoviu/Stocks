//
//  DetailedViewControlelr.swift
//  Stocks
//
//  Created by Oleg on 09.04.2023.
//

import Foundation
import UIKit
import Charts

protocol DetailedViewProtocol: AnyObject {
    func config(model: StockCoreDataModel)
}

class DetailedViewController: UIViewController, DetailedViewProtocol {
    var presenter: DetailedPresenterProtocol?
    
    private var chart = LineChartView(frame: CGRect(x: 0, y: 400, width: 300, height: 100))
    private var primaryMenu = PrimaryMenu()
    private let favoriteButton = UIButton(type: .system)
    private let backButton = UIButton(type: .system)
    private let tickerNameLabel = UILabel()
    private let companyNameLabel = UILabel()
    private let stockPrice = UILabel()
    private let deltaPrice = UILabel()
    
    var entries = [ChartDataEntry]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        setConstraints()
        setupViews()
        createGestureRecognizer()
        configCharty()
        presenter?.viewDidLoad()
    }
    
    func config(model: StockCoreDataModel) {
        navigationItem.titleView = makeNavigationBar(tickerName: model.ticker, companyName: model.name)
        stockPrice.text = "\(model.c)$"
        deltaPrice.text = "\(model.d)$ (\(round(model.dp * 100)/100)%)"
        changeColorDelta(deltaPrice: model.d, deltaProcent: model.dp)
        buttonSelected(bool: model.isFavorite)
    }
    
    private func changeColorDelta(deltaPrice: Double, deltaProcent: Double) {
        if deltaPrice < 0 {
            self.deltaPrice.textColor = UIColor(red: 0.70, green: 0.14, blue: 0.14, alpha: 1.00)
        } else {
            self.deltaPrice.textColor = UIColor(red: 0.14, green: 0.70, blue: 0.14, alpha: 1.00)
            self.deltaPrice.text = "+\(deltaPrice)$ (\(round(deltaProcent * 100)/100)%)"
        }
    }
    
    func setConstraints() {
        primaryMenu.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        primaryMenu.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        primaryMenu.heightAnchor.constraint(equalToConstant: 55).isActive = true
        primaryMenu.bottomAnchor.constraint(equalTo: stockPrice.topAnchor, constant: -45).isActive = true
    }
    
    func createGestureRecognizer() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
    }
    
    @objc func swipeRight(gestureRecognizer: UIPanGestureRecognizer) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func configUI() {
        favoriteButton.addTarget(self, action: #selector(tapFavoriteButton), for: .touchUpInside)
        var configuration = UIButton.Configuration.filled()
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 40, leading: 40, bottom: 40, trailing: 0)
        favoriteButton.configuration = configuration
        favoriteButton.configuration?.baseBackgroundColor = .clear
        
        backButton.setImage(UIImage(named: "back"), for: .normal)
        backButton.tintColor = .black
        backButton.addTarget(self, action: #selector(tapBackButton), for: .touchUpInside)
        
        stockPrice.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        stockPrice.center = CGPoint(x: view.frame.width / 2, y: 220)
        stockPrice.font = UIFont(name: "Montserrat-Bold", size: 28)
        stockPrice.textAlignment = .center
        
        deltaPrice.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        deltaPrice.center = CGPoint(x: view.frame.width / 2, y: 255)
        deltaPrice.font = UIFont(name: "Montserrat-SemiBold", size: 12)
        deltaPrice.textAlignment = .center
        
        primaryMenu.backgroundColor = .white
        primaryMenu.delegate = self
        primaryMenu.configure(with: ["Chart", "Summary", "News", "Forecast"])
        primaryMenu.addBottomShadow()
        
        navigationItem.titleView?.backgroundColor = .white
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.barStyle = UIBarStyle.default
        navigationController?.navigationBar.tintColor = UIColor.black
     
        view.addSubview(stockPrice)
        view.addSubview(deltaPrice)
        view.addSubview(primaryMenu)
        view.addSubview(chart)
    }
    
    func configCharty() {
        let entry = ChartDataEntry(x: Double(40), y: 30)
        entries.append(entry)
        let dataSet = LineChartDataSet(entries: entries, label: "Line Chart")
        dataSet.colors = [UIColor.black]
        dataSet.drawCirclesEnabled = false
        let data = LineChartData(dataSet: dataSet)
        chart.data = data
        chart.xAxis.labelPosition = .bottom // Настройте позицию меток по оси x
        chart.rightAxis.enabled = false // Отключите правую ось
        chart.legend.enabled = false
        chart.notifyDataSetChanged()
    }
    
    private func setupViews() {
        let rightBarButtonItem = UIBarButtonItem(customView: favoriteButton)
        let leftBarButtonItem = UIBarButtonItem(customView: backButton)
        
        navigationItem.rightBarButtonItem?.customView?.superview?.backgroundColor = .clear
        navigationItem.rightBarButtonItem?.tintColor = .white
        navigationItem.rightBarButtonItem = rightBarButtonItem
        navigationItem.leftBarButtonItem = leftBarButtonItem
    }
    
    private func makeNavigationBar(tickerName: String, companyName: String) -> UIView {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 200)
        
        tickerNameLabel.text = tickerName
        tickerNameLabel.textColor = .black
        tickerNameLabel.textAlignment = .center
        tickerNameLabel.frame = CGRect(x: 0, y: 1000, width: 100, height: 20)
        tickerNameLabel.center = CGPoint(x: view.frame.width / 2, y: 8)
        tickerNameLabel.font = UIFont(name: "Montserrat-Bold", size: 18)
        view.addSubview(tickerNameLabel)
        
        companyNameLabel.text = companyName
        companyNameLabel.textColor = .black
        companyNameLabel.textAlignment = .center
        companyNameLabel.frame = CGRect(x: 0, y: 28, width: 280, height: 20)
        companyNameLabel.center = CGPoint(x: view.frame.width / 2, y: 35)
        companyNameLabel.font = UIFont(name: "Montserrat-SemiBold", size: 14)
        view.addSubview(companyNameLabel)
        
        return view
    }
    
    func buttonSelected(bool: Bool) {
        if bool == true {
            favoriteButton.setImage(UIImage(named: "selected"), for: .normal)
            navigationItem.rightBarButtonItem?.customView?.tintColor = UIColor(red: 1.00, green: 0.79, blue: 0.11, alpha: 1.00)
        } else {
            favoriteButton.setImage(UIImage(named: "Star 1"), for: .normal)
            navigationItem.rightBarButtonItem?.customView?.tintColor = UIColor(red: 0.73, green: 0.73, blue: 0.73, alpha: 1.00)
        }
    }
    
    @objc func tapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func tapFavoriteButton() {
        if favoriteButton.imageView?.image == UIImage(named: "selected")  {
            navigationItem.rightBarButtonItem?.customView?.tintColor = UIColor(red: 0.73, green: 0.73, blue: 0.73, alpha: 1.00)
            buttonSelected(bool: false)
            favoriteButton.isSelected = !favoriteButton.isSelected
            guard let ticker = tickerNameLabel.text else { return }
            
            presenter?.changeIsFavorite(bool: false, ticker: ticker)
        } else if favoriteButton.imageView?.image == UIImage(named: "Star 1") {
            navigationItem.rightBarButtonItem?.customView?.tintColor = UIColor(red: 1.00, green: 0.79, blue: 0.11, alpha: 1.00)
            buttonSelected(bool: true)
            favoriteButton.isSelected = !favoriteButton.isSelected
            guard let ticker = tickerNameLabel.text else { return }
            
            presenter?.changeIsFavorite(bool: true, ticker: ticker)
        }
    }
    
    
    func setChartConstraints() {
        
    }
}

extension DetailedViewController: MenuStackDelegate {
    func changeMenu(index: Int) {
        print("GAGA")
    }
}

extension UIView {
    func addBottomShadow() {
        layer.masksToBounds = false
        layer.shadowRadius = 1
        layer.shadowOpacity = 1
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width: 0 , height: 2)
    }
}
