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
    
    func update(with stock: Company) {
        let request: NSFetchRequest<StockCoreDataModel> = StockCoreDataModel.fetchRequest()
        request.predicate = NSPredicate(format: "ticker == %@", stock.ticker)
        
        do {
            let models = try context.fetch(request)
            
            guard !models.isEmpty else {
                addStock(stock: stock)
                return
            }
            
            models[0].ticker = stock.ticker
            models[0].name = stock.name
            models[0].logo = stock.logo
//            models[0].d = stock.quote.d
//            models[0].c = stock.quote.c
//            models[0].dp = stock.quote.dp
            
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
    
    func addStock(stock: Company) {
        let entity = NSEntityDescription.entity(forEntityName: "StockCoreDataModel", in: context)
        let taskObject = NSManagedObject(entity: entity!, insertInto: context) as! StockCoreDataModel
        
        taskObject.name = stock.name
        taskObject.ticker = stock.ticker
        taskObject.logo = stock.logo
//        taskObject.c = stock.quote.c
//        taskObject.d = stock.quote.d
//        taskObject.dp = stock.quote.dp
        
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
}
