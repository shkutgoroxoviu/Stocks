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

}

extension StockCoreDataModel : Identifiable {

}
