//
//  UIImageView + Load.swift
//  Stocks
//
//  Created by Гурген Хоршикян on 04.02.2023.
//


import UIKit
import SVGKit
import SDWebImage

class ImageCache {

    private init() {}

    static let shared = NSCache<NSString, UIImage>()
}

class CustomImageView: UIImageView {
    let spinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
    
    func load(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        image = nil
        
        addSpinner()

        if let imageFromCache = ImageCache.shared.object(forKey: urlString as NSString) {
            image = imageFromCache
            stopSpinner()
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    if let rI = SVGKImage(data: data) {
                        ImageCache.shared.setObject(rI.uiImage, forKey: urlString as NSString)
                        self.image = rI.uiImage
                        self.stopSpinner()
                    }
                }
            }
        }.resume()
    }
    
    func addSpinner() {
        addSubview(spinner)
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        spinner.startAnimating()
    }
    
    func stopSpinner() {
        spinner.stopAnimating()
    }
}


