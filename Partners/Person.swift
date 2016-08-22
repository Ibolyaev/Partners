//
//  Person.swift
//  Partners
//
//  Created by Admin on 14.07.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON


@objc(Person)


class Person : NSManagedObject {
    
    struct Keys {
        static let Name = "Description"
        static let RefKey = "Ref_Key"
        static let Role = "ДолжностьПоВизитке"
        static let OwnerRefKey = "Owner_Key"
        
    }
    class func getCollectionName() -> String {
        return "/Catalog_КонтактныеЛицаПартнеров?"
    }

    
    @NSManaged var name: String
    @NSManaged var refKey: String
    @NSManaged var role: String
    @NSManaged var ownerRefKey: String
    @NSManaged var partner: Partner
    @NSManaged var contactInfo: [ContactInfo]
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    
    init(json: JSON, context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("Person", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        name = json[Keys.Name].string!
        refKey = json[Keys.RefKey].string!
        role = json[Keys.Role].string!
        
        ownerRefKey = json[Keys.OwnerRefKey].string!
        let findedPartner = Person.getPartnerbyReferenceKey(ownerRefKey,context: context)
        if let partner = findedPartner {
            self.partner = partner
        }
        
        /*self.partner = partner
        self.contactInfo = contactInfo*/
        
        
    }
    
    class func getPartnerbyReferenceKey(ownerRefKey:String,context: NSManagedObjectContext) -> Partner?{
        
        let fetchRequest = NSFetchRequest(entityName: "Partner")
        
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "refKey", ascending: true)]
        
            
        let firstNamePredicate = NSPredicate(format: "refKey == %@", ownerRefKey)
        
        let predicate = NSCompoundPredicate.init(orPredicateWithSubpredicates: [firstNamePredicate])
        
        fetchRequest.predicate = predicate
        
        let count = context.countForFetchRequest(fetchRequest, error: nil)
        
        if count > 0 {
            let resault = (try! context.executeFetchRequest(fetchRequest)) as! [Partner]
            
            for element in resault {
                
                return element
            }
            
        }

        return nil
      
    }
    
    class func updateObject(person:Person,json: JSON,context: NSManagedObjectContext) {
        person.name = json[Keys.Name].string!
        person.refKey = json[Keys.RefKey].string!
        person.role = json[Keys.Role].string!
        
        let findedPartner = Person.getPartnerbyReferenceKey(person.ownerRefKey,context: context)
        if let partner = findedPartner {
            person.partner = partner
        }

    }
    
    class func loadUpdateInfo(json: JSON, context: NSManagedObjectContext) -> Person {
        
        let fetchRequest = NSFetchRequest(entityName: "Person")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "refKey", ascending: true)]
        
        let firstNamePredicate = NSPredicate(format: "refKey == %@", json[Keys.RefKey].string!)
        
        let predicate = NSCompoundPredicate.init(orPredicateWithSubpredicates: [firstNamePredicate])
                
        fetchRequest.predicate = predicate
        
        let count = context.countForFetchRequest(fetchRequest, error: nil)
        
        if count > 0 {
            let resault = (try! context.executeFetchRequest(fetchRequest)) as! [Person]
            
            for element in resault {
                updateObject(element,json: json,context: context)
                CoreDataStackManager.sharedInstance().saveContext()
                return element
            }
            
        }
        
        
        return Person(json: json, context: context)
        
    }
    

}
