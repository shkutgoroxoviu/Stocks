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
    
    //    func fetchOneElement(name: String) -> StockCoreDataModel? {
    //        // Создаем запрос в базу данных, который возвращает все элементы
    //        let request: NSFetchRequest<StockCoreDataModel> = StockCoreDataModel.fetchRequest()
    //        // Добавляем параметр для запроса, чтобы получить определенный элемент
    //        request.predicate = NSPredicate(format: "companyProfile == %@", name)
    //
    //        do {
    //            let model = try context.fetch(request)
    //
    //            guard !model.isEmpty else {
    //                return nil
    //            }
    //            return model[0]
    //        } catch {
    //            print(error.localizedDescription)
    //            return nil
    //        }
    //    }
    
    func update(with stock: Company, quote: Quote) {
        let request: NSFetchRequest<StockCoreDataModel> = StockCoreDataModel.fetchRequest()
        request.predicate = NSPredicate(format: "ticker == %@", stock.ticker)
        
        do {
            let models = try context.fetch(request)
            
            guard !models.isEmpty else {
                addStock(stock: stock, quote: quote)
                return
            }
            
            models[0].ticker = stock.ticker
            models[0].name = stock.name
            models[0].logo = stock.logo
            models[0].c = quote.c
            models[0].d = quote.d
            models[0].dp = quote.dp
            
            try context.save()
            print("\(stock.ticker) update ✅✅✅")
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
    
    func addStock(stock: Company, quote: Quote) {
        let entity = NSEntityDescription.entity(forEntityName: "StockCoreDataModel", in: context)
        let taskObject = NSManagedObject(entity: entity!, insertInto: context) as! StockCoreDataModel
        
        taskObject.name = stock.name
        taskObject.ticker = stock.ticker
        taskObject.logo = stock.logo
        taskObject.c = quote.c
        taskObject.d = quote.d
        taskObject.dp = quote.dp
        
        do {
            try context.save()
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
