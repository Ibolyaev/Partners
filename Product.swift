//
//  Product.swift
//  Partners
//
//  Created by Admin on 30.07.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import Foundation
import CoreData
@objc(Product)

class Product: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var refKey: String
    @NSManaged var pictureRefKey: String
    @NSManaged var price: NSNumber
    @NSManaged var picture: NSData
    struct Keys {
        static let Name = "Description"
        static let RefKey = "Ref_Key"
        static let PictureRefKey = "ФайлКартинки_Key"
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("Product", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        name = dictionary[Keys.Name] as! String
        refKey = dictionary[Keys.RefKey] as! String
        pictureRefKey = dictionary[Keys.PictureRefKey] as! String
    }
    
    class func getCollectionName() -> String {
        return "/Catalog_Номенклатура?"
    }
    class func getPicturesCollectionName() -> String {
        return "/InformationRegister_ПрисоединенныеФайлы?"
    }
    class func getPriceCollectionName() -> String {
        return "/InformationRegister_ЦеныНоменклатуры_RecordType/SliceLast()?"
    }
        
    class func getODataType() -> dataType {
        
        return dataType.Catalog_Номенклатура
    }
    class func getODataTypePicturesCollection() -> dataType {
        
        return dataType.InformationRegister_ПрисоединенныеФайлы
    }
    class func getODataTypePrice() -> dataType {
        
        return dataType.InformationRegister_ЦеныНоменклатуры_RecordType
    }

    class func updateObject(product:Product,dictionary: [String : AnyObject]) {
        product.name = dictionary[Keys.Name] as! String
        product.refKey = dictionary[Keys.RefKey] as! String
        product.pictureRefKey = dictionary[Keys.PictureRefKey] as! String
    }
    class func loadUpdateInfo(dictionary: [String : AnyObject], context: NSManagedObjectContext) -> Product {
        
        let fetchRequest = NSFetchRequest(entityName: "Product")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "refKey", ascending: true)]
        
        let firstNamePredicate = NSPredicate(format: "refKey == %@", dictionary[Keys.RefKey] as! String)
        
        let predicate = NSCompoundPredicate.orPredicateWithSubpredicates([firstNamePredicate])
        
        fetchRequest.predicate = predicate
        
        let count = context.countForFetchRequest(fetchRequest, error: nil)
        
        if count > 0 {
            let resault = context.executeFetchRequest(fetchRequest, error: nil) as! [Product]
            
            for element in resault {
                updateObject(element,dictionary: dictionary)
                CoreDataStackManager.sharedInstance().saveContext()
                return element
            }
            
        }
        
        return Product(dictionary: dictionary, context: context)
        
    }
    
    class func getProductByPictureReferenceKey(pictureRefKey:String,context: NSManagedObjectContext) -> Product?{
        
        let fetchRequest = NSFetchRequest(entityName: "Product")
                
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "pictureRefKey", ascending: true)]
        
        let pictureRefKeyPredicate = NSPredicate(format: "pictureRefKey == %@", pictureRefKey)
        
        let predicate = NSCompoundPredicate.orPredicateWithSubpredicates([pictureRefKeyPredicate])
        
        fetchRequest.predicate = predicate
        
        let count = context.countForFetchRequest(fetchRequest, error: nil)
        
        if count > 0 {
            let resault = context.executeFetchRequest(fetchRequest, error: nil) as! [Product]
            
            for element in resault {
                
                return element
            }
            
        }
        
        return nil
        
    }
    class func getProductByReferenceKey(refKey:String,context: NSManagedObjectContext) -> Product?{
        
        let fetchRequest = NSFetchRequest(entityName: "Product")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "refKey", ascending: true)]
        
        let pictureRefKeyPredicate = NSPredicate(format: "refKey == %@", refKey)
        
        let predicate = NSCompoundPredicate.orPredicateWithSubpredicates([pictureRefKeyPredicate])
        
        fetchRequest.predicate = predicate
        
        let count = context.countForFetchRequest(fetchRequest, error: nil)
        
        if count > 0 {
            let resault = context.executeFetchRequest(fetchRequest, error: nil) as! [Product]
            
            for element in resault {
                
                return element
            }
            
        }
        
        return nil
        
    }

}
