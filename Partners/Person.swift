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
    }
    
    
    @NSManaged var name: String
    @NSManaged var refKey: String
    @NSManaged var partner: Partner
    @NSManaged var contactInfo: [ContactInfo]
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    
    init(partner:Partner, contactInfo: [ContactInfo],dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        
        let entity =  NSEntityDescription.entityForName("Person", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        
        name = dictionary[Keys.Name] as! String
        refKey = dictionary[Keys.RefKey] as! String
        self.partner = partner
        self.contactInfo = contactInfo
        
        
    }
}
