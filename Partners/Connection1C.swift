//
//  Connection1C.swift
//  Partners
//
//  Created by Admin on 30.07.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import Foundation
import CoreData

class Connection1C: NSObject  {
    
    var session: NSURLSession
    typealias CompletionHander = (result: AnyObject!, error: NSError?) -> Void
    
    
        override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    func taskForGetMethod(collectionName: String, filter: OdataFilter, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        
        var dataCollection = ODataCollectionManager()
        
        dataCollection.setCollectionName(collectionName)
        
        dataCollection.makeAsynchronousRequestToCollection(filter) { (result, response, error) -> Void in
            
            /* Parse the data and use the data (happens in completion handler) */
            
            if let error = error {
                let newError = Connection1C.errorForData(result, response: response, error: error)
                completionHandler(result: nil, error: error)
            } else {
                
                Connection1C.parseJSONWithCompletionHandler(result, completionHandler: completionHandler)
            }
            
        }
    
    }
    
    
    func loadCollection(collectionName: String, sharedContext: NSManagedObjectContext,completionHandler: (result: Bool, error: NSError?) -> Void) {
        
        var filter = OdataFilter()
        //filter.addFilter("DeletionMark", filterValue: "false", filterOperand: "eq", clauseOperand: "")
        
        
        taskForGetMethod(collectionName, filter: filter) { (result, error) -> Void in
            
            
            if let result: AnyObject = result {
                
                let jsonResault = JSON(result)?[key:"value"] as? NSArray
                let odataMetadata = JSON(result)?[key:"odata.metadata"] as? NSString
                
                var odataType = ""
                
                if let odataMetadata = odataMetadata {
                    
                    let string = odataMetadata as String
                    
                    let needle: Character = "#"
                    if let idx = find(string, needle) {
                        let pos = distance(string.startIndex, idx)
                        
                        odataType = string.substringFromIndex(advance(string.startIndex,pos+1))
                        
                    }
                    else {
                        let err = NSError(domain: "Connection1C", code: 1, userInfo: [NSLocalizedDescriptionKey:"Unkown data type: \(odataType)"])
                        completionHandler(result: false, error: err)
                        
                    }
                }else{
                    let err = NSError(domain: "Connection1C", code: 1, userInfo: [NSLocalizedDescriptionKey:"Unkown data type: \(odataType)"])
                    completionHandler(result: false, error: err)
                    
                }
                
                
                
                switch odataType {
                case Partner.getODataType().description:
                    if let jsonResault = jsonResault {
                         Connection1C.loadPartnersInfo(jsonResault,sharedContext: sharedContext)
                    }
                    completionHandler(result: true, error: nil)
                case Person.getODataType().description:
                    if let jsonResault = jsonResault {
                        Connection1C.loadPersonsInfo(jsonResault,sharedContext: sharedContext)
                    }
                    completionHandler(result: true, error: nil)
                case Product.getODataType().description:
                    if let jsonResault = jsonResault {
                        Connection1C.loadProductInfo(jsonResault,sharedContext: sharedContext)
                    }
                    completionHandler(result: true, error: nil)
                case Product.getODataTypePicturesCollection().description:
                    if let jsonResault = jsonResault {
                        Connection1C.loadProductPictures(jsonResault,sharedContext: sharedContext)
                    }
                    completionHandler(result: true, error: nil)
                case Product.getODataTypePrice().description:
                    if let jsonResault = jsonResault {
                        Connection1C.loadProductPrice(jsonResault,sharedContext: sharedContext)
                    }
                    completionHandler(result: true, error: nil)
                case Order.getODataType().description:
                    if let jsonResault = jsonResault {
                        Connection1C.loadOrders(jsonResault, sharedContext: sharedContext)
                    }
                default:
                    return
                    
                }
                
            }else{
                completionHandler(result: false, error: error)
            }
        }
    }
   
    class func loadPartnersInfo(jsonResault:NSArray,sharedContext:NSManagedObjectContext) {
        
        for var i=0;i<jsonResault.count; i++ {
            let contactJSON = jsonResault.objectAtIndex(i) as! JSONValue
            
            let contactInfoJSON = contactJSON[key:ContactInfo.Keys.ContactInfoText] as? NSArray
            
            let partner = Partner.loadUpdateInfo(contactJSON as! [String : AnyObject], context: sharedContext)
            
            ContactInfo.loadUpdateInfoPartner(partner, contactInfoJSON: contactInfoJSON, context: sharedContext)
            CoreDataStackManager.sharedInstance().saveContext()
            
        }
    }
    class func loadProductInfo(jsonResault:NSArray,sharedContext:NSManagedObjectContext) {
        
        for var i=0;i<jsonResault.count; i++ {
            let contactJSON = jsonResault.objectAtIndex(i) as! JSONValue
                    
            let product = Product.loadUpdateInfo(contactJSON as! [String : AnyObject], context: sharedContext)
                        
            CoreDataStackManager.sharedInstance().saveContext()
            
        }
    }
    class func loadOrders(jsonResault:NSArray,sharedContext:NSManagedObjectContext) {
        
        for var i=0;i<jsonResault.count; i++ {
            let contactJSON = jsonResault.objectAtIndex(i) as! JSONValue
            
            let product = Order.loadUpdateInfo(contactJSON as! [String : AnyObject], context: sharedContext)
            
            CoreDataStackManager.sharedInstance().saveContext()
            
        }
    }

    class func loadProductPictures(jsonResault:NSArray,sharedContext:NSManagedObjectContext) {
        
        for var i=0;i<jsonResault.count; i++ {
            
            let jsonValue = jsonResault.objectAtIndex(i) as! JSONValue
            
            
            let pictureRefKey = jsonValue[key:"ПрисоединенныйФайл"] as! String
            
            let product = Product.getProductByPictureReferenceKey(pictureRefKey, context: sharedContext)
            
            if let product = product {
                let base64String = jsonValue[key:"ХранимыйФайл_Base64Data"] as! String
                let decodedData = NSData(base64EncodedString: base64String, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
                if let decodedData = decodedData {
                    
                    product.picture = decodedData
                    CoreDataStackManager.sharedInstance().saveContext()
                }
                
            }
        }
    }
    class func loadProductPrice(jsonResault:NSArray,sharedContext:NSManagedObjectContext) {
        
        for var i=0;i<jsonResault.count; i++ {
            
            let jsonValue = jsonResault.objectAtIndex(i) as! JSONValue
            
            
            let productRefKey = jsonValue[key:"Номенклатура_Key"] as! String
            
            let product = Product.getProductByReferenceKey(productRefKey, context: sharedContext)
            
            if let product = product {
                let price = jsonValue[key:"Цена"] as! Int
                
                product.price = price
                CoreDataStackManager.sharedInstance().saveContext()
                
            }
        }
    }
    


    class func loadPersonsInfo(jsonResault:NSArray,sharedContext:NSManagedObjectContext) {
        
        
        for var i=0;i<jsonResault.count; i++ {
            let contactJSON = jsonResault.objectAtIndex(i) as! JSONValue
            
            let contactInfoJSON = contactJSON[key:ContactInfo.Keys.ContactInfoText] as? NSArray
            
            let person = Person.loadUpdateInfo(contactJSON as! [String : AnyObject], context: sharedContext)
            
            ContactInfo.loadUpdateInfoPerson(person, contactInfoJSON: contactInfoJSON, context: sharedContext)
            CoreDataStackManager.sharedInstance().saveContext()
        }

    }

      /* Helper: Given a response with error, see if a status_message is returned, otherwise return the previous error */
    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {

        if let parsedResult = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil) as? [String : AnyObject] {

            return NSError(domain: "Connection1C Error", code: 1, userInfo: nil)
        }

        return error
    }

    // Parsing the JSON
    
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: CompletionHander) {
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
        
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            
            completionHandler(result: parsedResult, error: nil)
        }
    }

    // MARK: - Shared Instance
    
    class func sharedInstance() -> Connection1C {
        
        struct Singleton {
            static var sharedInstance = Connection1C()
        }
        
        return Singleton.sharedInstance
    }

    
}

enum dataType : Printable {  // Swift 2.0; for < 2.0 use Printable
    case InformationRegister_ЦеныНоменклатуры_RecordType
    case Catalog_Номенклатура
    case InformationRegister_ПрисоединенныеФайлы
    case Catalog_Партнеры
    case Catalog_КонтактныеЛицаПартнеров
    case Document_ЗаказКлиента
    
    var description : String {
        switch self {
            // Use Internationalization, as appropriate.
        case .InformationRegister_ЦеныНоменклатуры_RecordType: return "InformationRegister_ЦеныНоменклатуры_RecordType"
        case .Catalog_Номенклатура: return "Catalog_Номенклатура"
        case .Catalog_Партнеры: return "Catalog_Партнеры"
        case .Catalog_КонтактныеЛицаПартнеров: return "Catalog_КонтактныеЛицаПартнеров"
        case .InformationRegister_ПрисоединенныеФайлы: return "InformationRegister_ПрисоединенныеФайлы"
        case .Document_ЗаказКлиента: return "Document_ЗаказКлиента"
        }
    }
}



