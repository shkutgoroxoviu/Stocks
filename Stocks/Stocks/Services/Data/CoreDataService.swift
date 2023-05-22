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
    
    func fetchOneElement(name: String) -> StockCoreDataModel? {
        // Создаем запрос в базу данных, который возвращает все элементы
        let request: NSFetchRequest<StockCoreDataModel> = StockCoreDataModel.fetchRequest()
        // Добавляем параметр для запроса, чтобы получить определенный элемент
        request.predicate = NSPredicate(format: "ticker == %@", name)
        
        do {
            let model = try context.fetch(request)
            
            guard !model.isEmpty else {
                return nil
            }
            return model[0]
        } catch {
            print(error.localizedDescription)
            return nil
        }
        }
    
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
            models[0].country = stock.companyProfile.country
            models[0].currency = stock.companyProfile.currency
            models[0].exchange = stock.companyProfile.exchange
            models[0].ipo = stock.companyProfile.ipo
            models[0].marketCapitalization = stock.companyProfile.marketCapitalization
            models[0].phone = stock.companyProfile.phone
            models[0].typeOfServices = stock.companyProfile.finnhubIndustry
            models[0].weburl = stock.companyProfile.weburl
            models[0].shareOutstanding = stock.companyProfile.shareOutstanding
        
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
        taskObject.country = stock.companyProfile.country
        taskObject.currency = stock.companyProfile.currency
        taskObject.exchange = stock.companyProfile.exchange
        taskObject.ipo = stock.companyProfile.ipo
        taskObject.marketCapitalization = stock.companyProfile.marketCapitalization
        taskObject.phone = stock.companyProfile.phone
        taskObject.typeOfServices = stock.companyProfile.finnhubIndustry
        taskObject.weburl = stock.companyProfile.weburl
        
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
            if tickerModel.isFavorite == false {
                deleteStock(tickerModel.ticker)
            }
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
