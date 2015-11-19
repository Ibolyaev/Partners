//
//  Order_Products.swift
//  Partners
//
//  Created by Admin on 14.08.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import Foundation
import CoreData
@objc(Order_Products)

class Order_Products: NSManagedObject {

    @NSManaged var count: NSNumber
    @NSManaged var price: NSNumber
    @NSManaged var order: NSManagedObject
    @NSManaged var product: Product
    
    struct Keys {
        static let Count = "Количество"
        static let RefKey = "Ref_Key"
        static let Price = "Цена"
        static let ProductRefKey = "Номенклатура_Key"
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("Order_Products", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        count = dictionary[Keys.Count] as! NSNumber
        price = dictionary[Keys.Price] as! NSNumber
        
    }

}
