//
//  ContactInfo.swift
//  Partners
//
//  Created by Admin on 17.07.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import Foundation
import CoreData


@objc(ContactInfo)


class ContactInfo : NSManagedObject {
    
    struct Keys {
        
        static let Name = "Представление"
        static let TelephoneNumber = "НомерТелефона"
        static let TypeContact = "Тип"
        static let RefKey = "Ref_Key"
        
    }
    
    @NSManaged var name: String
    @NSManaged var refKey: String
    @NSManaged var typeContact: String
    @NSManaged var telephoneNumber: String
    
    @NSManaged var contactInfo: [ContactInfo]
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        
        let entity =  NSEntityDescription.entityForName("ContactInfo", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        
        name = dictionary[Keys.Name] as! String
        telephoneNumber = dictionary[Keys.TelephoneNumber] as! String
        typeContact = dictionary[Keys.TypeContact] as! String
        
        refKey = dictionary[Keys.RefKey] as! String
        
        
    }
}
