//
//  Order.swift
//  Partners
//
//  Created by Admin on 14.08.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import Foundation
import CoreData
@objc(Order)

class Order: NSManagedObject {

    @NSManaged var date: NSDate
    @NSManaged var refKey: String
    @NSManaged var shipmentDate: NSDate
    @NSManaged var status: String
    @NSManaged var totalSum: NSNumber
    @NSManaged var partner: Partner
    @NSManaged var products: NSOrderedSet
    @NSManaged var number: String
    
    struct Keys {
        static let Number = "Number"
        static let RefKey = "Ref_Key"
        static let Date = "Date"
        static let TotalSum = "СуммаДокумента"
        static let Products = "Товары"
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("Order", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        number = dictionary[Keys.Number] as! String
        refKey = dictionary[Keys.RefKey] as! String
        totalSum = dictionary[Keys.TotalSum] as! NSNumber
        
        var dateString = dictionary[Keys.Date] as! String
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'hh:mm:ss"
        date = dateFormatter.dateFromString(dateString)!
        
    }
    
    class func getCollectionName() -> String {
        return "/Document_ЗаказКлиента?"
    }
    
    class func getODataType() -> dataType {
        
        return dataType.Document_ЗаказКлиента
    }
    class func updateObject(order:Order,dictionary: [String : AnyObject]) {
        order.number = dictionary[Keys.Number] as! String
        order.refKey = dictionary[Keys.RefKey] as! String
        order.totalSum = dictionary[Keys.TotalSum] as! NSNumber
        var dateString = dictionary[Keys.Date] as! String
        
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'hh:mm:ss" //format style. Browse online to get a format that fits your needs.
        order.date = dateFormatter.dateFromString(dateString)!
        //order.date = dictionary[Keys.Date] as! NSDate

    }
    class func loadUpdateInfo(dictionary: [String : AnyObject], context: NSManagedObjectContext) -> Order {
        
        let fetchRequest = NSFetchRequest(entityName: "Order")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "refKey", ascending: true)]
        
        let firstNamePredicate = NSPredicate(format: "refKey == %@", dictionary[Keys.RefKey] as! String)
        
        let predicate = NSCompoundPredicate.orPredicateWithSubpredicates([firstNamePredicate])
        
        fetchRequest.predicate = predicate
        
        let count = context.countForFetchRequest(fetchRequest, error: nil)
        
        if count > 0 {
            let resault = context.executeFetchRequest(fetchRequest, error: nil) as! [Order]
            
            for element in resault {
                updateObject(element,dictionary: dictionary)
                CoreDataStackManager.sharedInstance().saveContext()
                return element
            }
            
        }
        
        var arrayOfProducts = dictionary[Keys.Products] as! NSArray
        
        
        
        return Order(dictionary: dictionary, context: context)
        
        
        
        
        
        
    }
    
    class func getOrderByReferenceKey(refKey:String,context: NSManagedObjectContext) -> Order?{
        
        let fetchRequest = NSFetchRequest(entityName: "Order")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "refKey", ascending: true)]
        
        let pictureRefKeyPredicate = NSPredicate(format: "refKey == %@", refKey)
        
        let predicate = NSCompoundPredicate.orPredicateWithSubpredicates([pictureRefKeyPredicate])
        
        fetchRequest.predicate = predicate
        
        let count = context.countForFetchRequest(fetchRequest, error: nil)
        
        if count > 0 {
            let resault = context.executeFetchRequest(fetchRequest, error: nil) as! [Order]
            
            for element in resault {
                
                return element
            }
            
        }
        
        return nil
        
    }


}
