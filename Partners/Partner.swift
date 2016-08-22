//
//  Partner.swift
//  Partners
//
//  Created by Admin on 14.07.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON


@objc(Partner)


class Partner : NSManagedObject {
    
    struct Keys {
        static let Name = "Description"
        static let RefKey = "Ref_Key"
        
    }
    
    
    @NSManaged var name: String
    @NSManaged var refKey: String
    @NSManaged var persons: [Person]
    @NSManaged var contactInfo: [ContactInfo]
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    
    init(json: JSON, context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("Partner", inManagedObjectContext: context)!
               super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        name = json[Keys.Name].string!
        refKey = json[Keys.RefKey].string!
        
    }
    
    class func getCollectionName() -> String {
        return "/Catalog_Партнеры?"
    }
        
    
    class func updateObject(partner:Partner,json: JSON) {
        partner.name = json[Keys.Name].string!
        partner.refKey = json[Keys.RefKey].string!
    }
    
    class func loadUpdateInfo(json: JSON, context: NSManagedObjectContext) -> Partner {
    
        let fetchRequest = NSFetchRequest(entityName: "Partner")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "refKey", ascending: true)]
        
        let firstNamePredicate = NSPredicate(format: "refKey == %@", json[Keys.RefKey].string!)
        
        let predicate = NSCompoundPredicate.init(andPredicateWithSubpredicates: [firstNamePredicate])
                
        fetchRequest.predicate = predicate
        
        let count = context.countForFetchRequest(fetchRequest, error: nil)
        
        if count > 0 {
            let resault = (try! context.executeFetchRequest(fetchRequest)) as! [Partner]
            
            for element in resault {
                updateObject(element,json: json)
                CoreDataStackManager.sharedInstance().saveContext()
                return element
            }
            
        }
        
        
        return Partner(json: json, context: context)
        
    }
    
        
    
}
