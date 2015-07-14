//
//  PartnersViewController.swift
//  Partners
//
//  Created by Admin on 13.07.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import Foundation
import UIKit

class PartnersViewController: UITableViewController,ODataCollectionDelegate, UITableViewDataSource {
    var partnersByName = [String: [JSONValue]]()
    var jsonResault: NSArray?
    
    //let partnersByName: [String:NSMutableArray]()
    //var partnersByName:[String:NSMutableArray()]()
    
    @IBAction func loadResaultsTouchUpInside(sender: UIBarButtonItem) {
        var filter = OdataFilter()
        /*filter.addFilter("Number", filterValue: "'000000012'", filterOperand: "eq", clauseOperand: "")*/
        var dataCollection = ODataCollectionManager()
        
        dataCollection.makeRequestToCollection(filter)
        dataCollection._delegate = self
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "contactCell")
        
        cell.textLabel?.text = jsonResault?[index: indexPath.row]?[key:"Description"] as! NSString as String
        
        return cell
        
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
        
        
        return NSArray(objects: "A" , "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "#")
        
 as [AnyObject]        
        
    }
    
    /*override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return partnersByName?.count!
        
    }*/
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let jsonResault = jsonResault {
            return jsonResault.count
        }
        
        return 0
        
    }
    
    func requestFailedWithError(error: NSString) {
        
        
    }
    
    func didRecieveResponse(results: NSDictionary) {
        
        
        jsonResault = JSON(results)?[key:"value"] as? NSArray
        
        
        for var i=0;i<jsonResault?.count; i++ {
            var element = jsonResault?.objectAtIndex(i) as! JSONValue
            
            var name = element[key:"Description"] as! NSString as String
            
            var ch = name[name.startIndex]
            
            var a = partnersByName[String(ch)]
            
            if a == nil {
                partnersByName[String(ch)] = [element]
            }else{
                var array = partnersByName[String(ch)]
                array?.append(element)
                partnersByName.updateValue(array!, forKey: String(ch))
            }
            
        }
        
        
        println(partnersByName)
        
        dispatch_async(dispatch_get_main_queue()) {
            
            self.tableView.reloadData()
            
        }
        
    }

}
