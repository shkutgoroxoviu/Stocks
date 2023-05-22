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
    
    func configChart()
    
    func startSpinner()
    
    func stopSpinner()
    
    func deleteThePreviousWindow()
    
    func reloadData()
}

class DetailedViewController: UIViewController, DetailedViewProtocol, ChartViewDelegate {
    var presenter: DetailedPresenterProtocol?
    
    private var chartView = LineChartView()
    private var primaryMenu = PrimaryMenu()
    private let favoriteButton = UIButton(type: .system)
    private let backButton = UIButton(type: .system)
    private let tickerNameLabel = UILabel()
    private let companyNameLabel = UILabel()
    private let stockPrice = UILabel()
    private let deltaPrice = UILabel()
    private var footerView = UIView()
    private var timeFramesMenu = TimeFramesMenu()
    private let buyButton = UIButton()
    let spinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
    
    var bool = true
    var currentIndex = 4
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        addSpinner()
        setPrimaryMenuConstraints()
        setTimeFrameMenuConstraints()
        setupViews()
        createGestureRecognizer()
        presenter?.viewDidLoad()
        configFooter()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        configChart()
    }
    
    func config(model: StockCoreDataModel) {
        buyButton.setTitle("Buy for $\(model.c)", for: .normal)
        navigationItem.titleView = makeNavigationBar(tickerName: model.ticker, companyName: model.name)
        stockPrice.text = "\(model.c)$"
        deltaPrice.text = "\(model.d)$ (\(round(model.dp * 100)/100)%)"
        changeColorDelta(deltaPrice: model.d, deltaProcent: model.dp)
        buttonSelected(bool: model.isFavorite)
    }
    
    private func configUI() {
        var configuration = UIButton.Configuration.filled()
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 40, leading: 40, bottom: 40, trailing: 0)
        favoriteButton.addTarget(self, action: #selector(tapFavoriteButton), for: .touchUpInside)
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
        
        chartView.delegate = self
        chartView.isUserInteractionEnabled = true
        
        timeFramesMenu.delegate = self
        timeFramesMenu.forceUpdatePosition(currentIndex)
        
        navigationItem.titleView?.backgroundColor = .white
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.barStyle = UIBarStyle.default
        navigationController?.navigationBar.tintColor = UIColor.black
     
        view.addSubview(stockPrice)
        view.addSubview(deltaPrice)
        view.addSubview(primaryMenu)
        view.addSubview(chartView)
    }
    
    func configFooter() {
        timeFramesMenu.configure(with: ["5", "15", "30", "60", "D", "W", "M"])

        buyButton.frame = CGRect(x: 0, y: 0, width: view.frame.width - 50, height: 60)
        buyButton.center = CGPoint(x: view.frame.width / 2, y: 220)
        buyButton.titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 16)
        buyButton.setTitleColor(.white, for: .normal)
        buyButton.backgroundColor = .black
        buyButton.layer.cornerRadius = 15
        buyButton.addTarget(self, action: #selector(clickBuyButton), for: .touchUpInside)
        
        footerView.frame = CGRect(x: 0, y: view.frame.maxY - 300, width: view.frame.width, height: 300)
        footerView.backgroundColor = UIColor(red: 0.988, green: 0.988, blue: 0.988, alpha: 1.00)
        footerView.addSubview(timeFramesMenu)
        footerView.addSubview(buyButton)
        
        view.addSubview(footerView)
    }
    
    func configChart() {
       guard let presenter = presenter else { return }
        
        chartView.frame = CGRect(x: 0, y: 270, width: view.frame.width, height: view.frame.height - 570)
        chartView.minOffset = 0
        
        chartView.xAxis.drawAxisLineEnabled = false
        chartView.xAxis.drawLimitLinesBehindDataEnabled = false
        chartView.xAxis.gridLineWidth = 0.5
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.xAxis.drawLabelsEnabled = false
        chartView.xAxis.axisLineColor = UIColor.clear
        chartView.drawGridBackgroundEnabled = false
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.enabled = false

        chartView.leftAxis.removeAllLimitLines()
        chartView.leftAxis.drawZeroLineEnabled = false
        chartView.leftAxis.zeroLineWidth = 0
        chartView.leftAxis.drawTopYLabelEntryEnabled = false
        chartView.leftAxis.drawAxisLineEnabled = false
        chartView.leftAxis.drawGridLinesEnabled = false
        chartView.leftAxis.drawLabelsEnabled = false
        chartView.leftAxis.drawLimitLinesBehindDataEnabled = false
        chartView.leftAxis.axisMinimum = 0
        chartView.leftAxis.labelCount = 10
        chartView.leftAxis.granularity = 100
        
        

        chartView.rightAxis.removeAllLimitLines()
        chartView.rightAxis.drawZeroLineEnabled = false
        chartView.rightAxis.drawTopYLabelEntryEnabled = false
        chartView.rightAxis.drawAxisLineEnabled = false
        chartView.rightAxis.drawGridLinesEnabled = false
        chartView.rightAxis.drawLabelsEnabled = false
        chartView.rightAxis.drawLimitLinesBehindDataEnabled = false
        chartView.rightAxis.enabled = false
        chartView.drawBordersEnabled = false
        chartView.backgroundColor = .clear
        chartView.legend.enabled = false
        chartView.doubleTapToZoomEnabled = false
        chartView.scaleYEnabled = false

        let gradientColors = [UIColor(red: 0.50, green: 0.50, blue: 0.50, alpha: 1.00).cgColor, UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1.00).cgColor]
        let colorLocations:[CGFloat] = [0.0, 1.0]
        guard let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors as CFArray, locations: colorLocations) else { return }
        
        let chartDataSet = LineChartDataSet(entries: presenter.dataEntries, label: "Stock Price")
        chartDataSet.colors = [.black]
        chartDataSet.mode = .cubicBezier
        chartDataSet.fill = LinearGradientFill(gradient: gradient, angle: 270)
        chartDataSet.drawValuesEnabled = false
        chartDataSet.drawCirclesEnabled = false
        chartDataSet.drawFilledEnabled = true
        chartDataSet.highlightEnabled = true
        chartDataSet.drawVerticalHighlightIndicatorEnabled = false
        chartDataSet.drawHorizontalHighlightIndicatorEnabled = false
        
        let chartData = LineChartData(dataSet: chartDataSet)
        chartView.data = chartData
    }
    
    func reloadData() {
        DispatchQueue.main.async {
            self.chartView.notifyDataSetChanged()
        }
    }
    
    func addSpinner() {
        view.addSubview(spinner)
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        spinner.startAnimating()
    }
    
    func startSpinner() {
        chartView.isHidden = true
        spinner.startAnimating()
    }
    
    func stopSpinner() {
        chartView.isHidden = false
        spinner.stopAnimating()
    }
   
    private func changeColorDelta(deltaPrice: Double, deltaProcent: Double) {
        if deltaPrice < 0 {
            self.deltaPrice.textColor = UIColor(red: 0.70, green: 0.14, blue: 0.14, alpha: 1.00)
        } else {
            self.deltaPrice.textColor = UIColor(red: 0.14, green: 0.70, blue: 0.14, alpha: 1.00)
            self.deltaPrice.text = "+\(deltaPrice)$ (\(round(deltaProcent * 100)/100)%)"
        }
    }
    
    func setTimeFrameMenuConstraints() {
        timeFramesMenu.frame = CGRect(x: 0, y: 0, width: view.frame.width - 10, height: 50)
        timeFramesMenu.center = CGPoint(x: view.frame.width / 2, y: 70)
    }
    
    func setPrimaryMenuConstraints() {
        primaryMenu.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        primaryMenu.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        primaryMenu.heightAnchor.constraint(equalToConstant: 55).isActive = true
        primaryMenu.bottomAnchor.constraint(equalTo: stockPrice.topAnchor, constant: -45).isActive = true
    }

    func createGestureRecognizer() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight))
        swipeRight.direction = .right
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(cancelHighlight))
        tap.cancelsTouchesInView = false
        tap.numberOfTapsRequired = 2
        
        chartView.addGestureRecognizer(tap)
        view.addGestureRecognizer(swipeRight)
    }
    
    @objc func cancelHighlight(gestureRecognizer: UITapGestureRecognizer) {
        deleteThePreviousWindow()
    }
    
    @objc func swipeRight(gestureRecognizer: UIPanGestureRecognizer) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func clickBuyButton() {
        guard let presenter = presenter else { return }
        let alert = UIAlertController(title: "\(presenter.model.ticker)", message: "Do you really want to buy \(presenter.model.ticker)?", preferredStyle: .alert)
        alert.modalPresentationStyle = .fullScreen
       
        let addActionAlert = UIAlertAction(title: "Yes", style: .default, handler: nil)
        let cancelActionAlert = UIAlertAction(title: "No", style: .default, handler: nil)
        
        alert.addAction(cancelActionAlert)
        alert.addAction(addActionAlert)
        alert.addTextField { (textField) in
                    textField.placeholder = "Enter the quantity"
                }
        
        present(alert, animated: true, completion: nil)
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        let circle = UIView(frame: CGRect(x: highlight.xPx - 5, y: highlight.yPx - 5, width: 10, height: 10))
        circle.backgroundColor = .black
        circle.layer.cornerRadius = 5
        circle.layer.borderWidth = 2
        circle.layer.shadowColor = UIColor.gray.cgColor
        circle.layer.shadowOffset = CGSize(width: 0, height: 2)
        circle.layer.shadowRadius = 5
        circle.layer.shadowOpacity = 0.5
        
        let popUpView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 70))
        popUpView.backgroundColor = .black
        popUpView.layer.cornerRadius = 20
        popUpView.layer.shadowColor = UIColor.gray.cgColor
        popUpView.layer.shadowOffset = CGSize(width: 0, height: 2)
        popUpView.layer.shadowRadius = 5
        popUpView.layer.shadowOpacity = 0.5
        popUpView.center = CGPoint(x: circle.center.x, y: circle.center.y - 60)
        
        guard let presenter = presenter else { return }
        let quoteLabel = UILabel(frame: CGRect(x: 0, y: 15, width: 100, height: 20))
        quoteLabel.text = "$\(presenter.candlesClosePrice[Int(entry.x)])"
        quoteLabel.textAlignment = .center
        quoteLabel.textColor = .white
        quoteLabel.font = UIFont(name: "Montserrat-SemiBold", size: 16)
        
        let dateLabel = UILabel(frame: CGRect(x: 0, y: 35, width: 100, height: 20))
        dateLabel.text = "\(convertationDate(enterDate:Int(presenter.candlesData[Int(entry.x)])))"
        dateLabel.textAlignment = .center
        dateLabel.textColor = UIColor(red: 0.73, green: 0.73, blue: 0.73, alpha: 1.00)
        dateLabel.font = UIFont(name: "Montserrat-SemiBold", size: 12)
        
        deleteThePreviousWindow()
        
        popUpView.addSubview(quoteLabel)
        popUpView.addSubview(dateLabel)
        self.chartView.addSubview(circle)
        self.chartView.addSubview(popUpView)
        self.chartView.highlightPerTapEnabled = true
    }
    
    func convertationDate(enterDate: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = Date(timeIntervalSince1970: TimeInterval(enterDate))
        let formattedDate = dateFormatter.string(from: date)
    
        return formattedDate
    }
    
    func deleteThePreviousWindow() {
        for subview in chartView.subviews {
            if subview is UIView || subview.layer.cornerRadius == 5 {
                subview.removeFromSuperview()
            }
        }
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

extension DetailedViewController {
    func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {
        if scaleX > 0 || scaleY > 0 {
            deleteThePreviousWindow()
        }
    }
    
    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
        if dX > 0 || dY > 0 {
            deleteThePreviousWindow()
        }
    }
}

extension DetailedViewController: TimeFrameDelegate {
    func changeFrame(index: Int) {
        currentIndex = index
        presenter?.changeMenu(index: currentIndex)
    }
}
