//
//  CoreDataService.swift
//  Stocks
//
//  Created by Гурген Хоршикян on 31.01.2023.
//
import UIKit
import CoreData

class CoreDataService {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    lazy var context = appDelegate.persistentContainer.viewContext
    
    func update(with stock: Stock) {
        let request: NSFetchRequest<StockCoreDataModel> = StockCoreDataModel.fetchRequest()
        request.predicate = NSPredicate(format: "ticker == %@", stock.companyProfile.ticker)
        
        do {
            let models = try context.fetch(request)
            
            guard !models.isEmpty else {
                addStock(stock: stock)
                return
            }
            
            models[0].ticker = stock.companyProfile.ticker
            models[0].name = stock.companyProfile.name
            models[0].logo = stock.companyProfile.logo
            models[0].c = stock.quote.c
            models[0].d = stock.quote.d
            models[0].dp = stock.quote.dp
            
            try context.save()
            print("\(stock.companyProfile.ticker) update ✅✅✅")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchStock() -> [StockCoreDataModel]? {
        let fetchRequest: NSFetchRequest<StockCoreDataModel> = StockCoreDataModel.fetchRequest()
        
        do {
            let models = try context.fetch(fetchRequest)
            return models
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func addStock(stock: Stock) {
        let entity = NSEntityDescription.entity(forEntityName: "StockCoreDataModel", in: context)
        let taskObject = NSManagedObject(entity: entity!, insertInto: context) as! StockCoreDataModel
        
        taskObject.name = stock.companyProfile.name
        taskObject.ticker = stock.companyProfile.ticker
        taskObject.logo = stock.companyProfile.logo
        taskObject.c = stock.quote.c
        taskObject.d = stock.quote.d
        taskObject.dp = stock.quote.dp
        
        do {
            try context.save()
            print("\(stock.companyProfile.ticker) add ✅✅✅")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteStock(_ ticker: String) {
           let fetchRequest: NSFetchRequest<StockCoreDataModel> = StockCoreDataModel.fetchRequest()
           fetchRequest.predicate = NSPredicate(format: "ticker == %@", ticker)
           
           do {
               let result = try context.fetch(fetchRequest)
               guard !result.isEmpty else { return }
               guard let tickerModel = result.first else { return}
               tickerModel.isFavorite = false
               context.delete(result[0])
               try context.save()
               print("\(ticker) delete ❌❌❌")
           } catch {
               print(error.localizedDescription)
           }
       }
    
    func changeToFavorite(tickerString: String, isFavorite: Bool) {
        
        let fetchRequest: NSFetchRequest<StockCoreDataModel> = StockCoreDataModel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "ticker == %@",  tickerString)
        
        do {
            let result = try context.fetch(fetchRequest)
            guard let tickerModel = result.first else { return}
            tickerModel.isFavorite = isFavorite
            
            try context.save()
            print(isFavorite ? "\(tickerString) save ✅✅✅" : "\(tickerString) delete ❌❌❌")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func checkToFavorite(from ticker: String) -> Bool {
        
        let fetchRequest: NSFetchRequest<StockCoreDataModel> = StockCoreDataModel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "ticker == %@",  ticker)
        
        do {
            if let result = try context.fetch(fetchRequest).first {
                return result.isFavorite
            }
        } catch {
            print(error.localizedDescription)
        }
        return false
    }
}
