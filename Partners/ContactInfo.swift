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
        static let ContactInfoText = "КонтактнаяИнформация"
        
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
        //kindOfCOntact = dictionary[Keys.KindOfCOntact] as! String
        kindOfCOntact = "test"
        
        
    }
    class func loadUpdateInfoPerson(person:Person, contactInfoJSON:NSArray?,context: NSManagedObjectContext) {
                
        if let contactInfoJSON = contactInfoJSON {
            
            // if its new partner witout contact info and in JSONdata we have something - create a new contact info
            if person.contactInfo.count != 0 && contactInfoJSON.count > 0 {
                
                //we need to update info becouse partner already have it
                // cant say which info were updated so we delete it first out of context and upload new one
                for el in person.contactInfo {
                    context.deleteObject(el)
                }
                
            }
            for el in contactInfoJSON {
                
                let contactInfo = ContactInfo(dictionary: el as! [String : AnyObject], context: context)
                contactInfo.person = person
                CoreDataStackManager.sharedInstance().saveContext()
                
            }
            
            
        }
    }


    
    class func loadUpdateInfoPartner(partner:Partner, contactInfoJSON:NSArray?,context: NSManagedObjectContext) {
        
        
        
        if let contactInfoJSON = contactInfoJSON {
            
            // if its new partner witout contact info and in JSONdata we have something - create a new contact info
            if partner.contactInfo.count != 0 && contactInfoJSON.count > 0 {
                
                //we need to update info becouse partner already have it
                // cant say which info were updated so we delete it first out of context and upload new one
                for el in partner.contactInfo {
                    context.deleteObject(el)
                }
                
            }
            for el in contactInfoJSON {
                
                let contactInfo = ContactInfo(dictionary: el as! [String : AnyObject], context: context)
                contactInfo.partner = partner
                CoreDataStackManager.sharedInstance().saveContext()
                
            }
            
            
        }
    }

}
