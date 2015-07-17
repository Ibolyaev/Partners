//
//  PartnersViewController.swift
//  Partners
//
//  Created by Admin on 13.07.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import Foundation
import UIKit

class PartnersViewController: UITableViewController,ODataCollectionDelegate, UITableViewDataSource,UITableViewDelegate {
    
    var partnersByName = NSMutableDictionary()
    var jsonResault: NSArray?
    var partnersTitles: NSArray?
    let indexTitles = NSArray(objects: "A" , "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "#")
        
        as [AnyObject]
    
    @IBAction func loadResaultsTouchUpInside(sender: UIBarButtonItem) {
        var filter = OdataFilter()
        /*filter.addFilter("Number", filterValue: "'000000012'", filterOperand: "eq", clauseOperand: "")*/
        var dataCollection = ODataCollectionManager()
        
        dataCollection.makeRequestToCollection(filter)
        dataCollection._delegate = self
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Make sure your segue name in storyboard is the same as this line
    
        var secondViewController : PartnerDetailInfo = segue.destinationViewController as! PartnerDetailInfo
        
        
        
        var indexPath = tableView.indexPathForSelectedRow() //get index of data for selected row
        
        
        let sectionTitle: AnyObject? = partnersTitles?.objectAtIndex(indexPath!.section)
        let sectionPartners = partnersByName.objectForKey(sectionTitle!) as! NSArray
        
        let partner = sectionPartners.objectAtIndex(indexPath!.row) as! JSONValue

        
        secondViewController.contactJSON = partner
        //println(segue.identifier)
    
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        performSegueWithIdentifier("segueToDetailView", sender: self)
        
        /*let contactView:ContactDetailViewController = self.storyboard!.instantiateViewControllerWithIdentifier("PartnerDetailInfo")! as! PartnerDetailInfo
        
        contactView.contactJSON = arrayOfJsonObjects?[indexPath.row] as! NSDictionary
        
        self.navigationController!.pushViewController(contactView, animated: true)*/
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "contactCell")
        
        let sectionTitle: AnyObject? = partnersTitles?.objectAtIndex(indexPath.section)
        let sectionPartners = partnersByName.objectForKey(sectionTitle!) as! NSArray
        
        let partner = sectionPartners.objectAtIndex(indexPath.row) as! JSONValue
        
        cell.textLabel?.text =  partner[key:"Description"] as! NSString as String
        
        return cell
        
    }
    
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        
        if let partnersTitles = partnersTitles {
            return partnersTitles.indexOfObject(title)
        }
        
        return 0
        
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
        
        return indexTitles
        
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let partnersTitles = partnersTitles {
            return partnersTitles.objectAtIndex(section) as? String
        }
        return ""

    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if let partnersTitles = partnersTitles {
            return partnersTitles.count
        }
        
        return 0
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Return the number of rows in the section.
        let sectionTitle: AnyObject? = partnersTitles?.objectAtIndex(section)
        let sectionParners = partnersByName.objectForKey(sectionTitle!) as! NSArray
        return sectionParners.count
        
    }
    
    func requestFailedWithError(error: NSString) {
        
        
    }
    
    func didRecieveResponse(results: NSDictionary) {
        
        
        jsonResault = JSON(results)?[key:"value"] as? NSArray
        
        
        for var i=0;i<jsonResault?.count; i++ {
            
            var element = jsonResault?.objectAtIndex(i) as! JSONValue
            
            let name = element[key:"Description"] as! NSString as String
            
            let ch = name[name.startIndex]
            
            let letter = String(ch)
            
            var a: AnyObject? = partnersByName[letter]
            
            if a == nil {
                partnersByName[letter] = NSArray(object: element as! AnyObject) as AnyObject
            }else{
                
                var array: AnyObject? = partnersByName[letter]
                
                array?.arrayByAddingObject(element as! AnyObject)
                
                partnersByName.setValue(array, forKey: letter)
                
            }
            
        }
        
        partnersTitles = partnersByName.allKeys
        partnersTitles?.sortedArrayUsingSelector(Selector("localizedCaseInsensitiveCompare:"))
        
        
        dispatch_async(dispatch_get_main_queue()) {
            
            self.tableView.reloadData()
            
        }
        
    }

}
