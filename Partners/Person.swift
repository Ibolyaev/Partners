//
//  Person.swift
//  Partners
//
//  Created by Admin on 14.07.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import Foundation
import CoreData


@objc(Person)


class Person : NSManagedObject {
    
    struct Keys {
        static let Name = "Description"
        static let RefKey = "Ref_Key"
        static let Role = "ДолжностьПоВизитке"
        
    }
    class func getCollectionName() -> String {
        return "/Catalog_КонтактныеЛицаПартнеров?"
    }

    
    @NSManaged var name: String
    @NSManaged var refKey: String
    @NSManaged var role: String
    @NSManaged var partner: Partner
    @NSManaged var contactInfo: [ContactInfo]
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        
        let entity =  NSEntityDescription.entityForName("Person", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        
        name = dictionary[Keys.Name] as! String
        refKey = dictionary[Keys.RefKey] as! String
        role = dictionary[Keys.Role] as! String
        /*self.partner = partner
        self.contactInfo = contactInfo*/
        
        
    }
    class func updateObject(person:Person,dictionary: [String : AnyObject]) {
        person.name = dictionary[Keys.Name] as! String
        person.refKey = dictionary[Keys.RefKey] as! String
    }
    
    class func loadUpdateInfo(dictionary: [String : AnyObject], context: NSManagedObjectContext) -> Person {
        
        let fetchRequest = NSFetchRequest(entityName: "Person")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "refKey", ascending: true)]
        
        let firstNamePredicate = NSPredicate(format: "refKey == %@", dictionary[Keys.RefKey] as! String)
        
        let predicate = NSCompoundPredicate.orPredicateWithSubpredicates([firstNamePredicate])
        
        fetchRequest.predicate = predicate
        
        let count = context.countForFetchRequest(fetchRequest, error: nil)
        
        if count > 0 {
            let resault = context.executeFetchRequest(fetchRequest, error: nil) as! [Person]
            
            for element in resault {
                updateObject(element,dictionary: dictionary)
                CoreDataStackManager.sharedInstance().saveContext()
                return element
            }
            
        }
        
        
        return Person(dictionary: dictionary, context: context)
        
    }
    

}
