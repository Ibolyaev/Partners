//
//  Partner.swift
//  Partners
//
//  Created by Admin on 14.07.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import Foundation
import CoreData


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
    
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("Partner", inManagedObjectContext: context)!
               super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        name = dictionary[Keys.Name] as! String
        refKey = dictionary[Keys.RefKey] as! String
        
    }
    
    class func getCollectionName() -> String {
        
        return "/Catalog_Партнеры?"
    }
    class func getODataType() -> dataType {
        
        return dataType.Catalog_Партнеры
    }
    
    
    
    
    class func updateObject(partner:Partner,dictionary: [String : AnyObject]) {
        partner.name = dictionary[Keys.Name] as! String
        partner.refKey = dictionary[Keys.RefKey] as! String
    }
    
    class func loadUpdateInfo(dictionary: [String : AnyObject], context: NSManagedObjectContext) -> Partner {
    
        let fetchRequest = NSFetchRequest(entityName: "Partner")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "refKey", ascending: true)]
        
        let firstNamePredicate = NSPredicate(format: "refKey == %@", dictionary[Keys.RefKey] as! String)
        
        let predicate = NSCompoundPredicate.orPredicateWithSubpredicates([firstNamePredicate])
        
        fetchRequest.predicate = predicate
        
        let count = context.countForFetchRequest(fetchRequest, error: nil)
        
        if count > 0 {
            let resault = context.executeFetchRequest(fetchRequest, error: nil) as! [Partner]
            
            for element in resault {
                updateObject(element,dictionary: dictionary)
                CoreDataStackManager.sharedInstance().saveContext()
                return element
            }
            
        }
        
        
        return Partner(dictionary: dictionary, context: context)
        
    }
    
        
    
}
