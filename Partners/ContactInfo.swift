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
        
        static let Info = "Представление"
        static let TelephoneNumber = "НомерТелефона"
        static let TypeContact = "Тип"
        static let KindOfCOntact = "Вид"
        static let RefKey = "Ref_Key"
        
        static let Telephone = "Телефон"
        static let Email = "АдресЭлектроннойПочты"
        
    }
    
    @NSManaged var info: String
    @NSManaged var refKey: String
    @NSManaged var typeContact: String
    @NSManaged var telephoneNumber: String
    @NSManaged var kindOfCOntact: String
    @NSManaged var person: Person?
    @NSManaged var partner: Partner?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        
        let entity =  NSEntityDescription.entityForName("ContactInfo", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        
        info = dictionary[Keys.Info] as! String
        telephoneNumber = dictionary[Keys.TelephoneNumber] as! String
        typeContact = dictionary[Keys.TypeContact] as! String
        
        refKey = dictionary[Keys.RefKey] as! String
        kindOfCOntact = dictionary[Keys.KindOfCOntact] as! String
        
        
        
    }
}
