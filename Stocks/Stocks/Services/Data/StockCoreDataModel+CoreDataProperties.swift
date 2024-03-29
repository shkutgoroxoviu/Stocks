//
//  StockCoreDataModel+CoreDataProperties.swift
//  Stocks
//
//  Created by Гурген Хоршикян on 31.01.2023.
//
//

import Foundation
import CoreData


extension StockCoreDataModel {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<StockCoreDataModel> {
        return NSFetchRequest<StockCoreDataModel>(entityName: "StockCoreDataModel")
    }
    
    @NSManaged public var name: String
    @NSManaged public var logo: String
    @NSManaged public var ticker: String
    @NSManaged public var c: Double
    @NSManaged public var d: Double
    @NSManaged public var dp: Double
    @NSManaged public var isFavorite: Bool
    @NSManaged public var currency: String
    @NSManaged public var exchange: String
    @NSManaged public var ipo: String
    @NSManaged public var marketCapitalization: Double
    @NSManaged public var phone: String
    @NSManaged public var typeOfServices: String
    @NSManaged public var weburl: String
    @NSManaged public var country: String
    @NSManaged public var shareOutstanding: Double
}

extension StockCoreDataModel : Identifiable {

}
