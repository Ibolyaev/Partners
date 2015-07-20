//
//  PartnersViewController.swift
//  Partners
//
//  Created by Admin on 13.07.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PartnersViewController: UITableViewController, NSFetchedResultsControllerDelegate, ODataCollectionDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var jsonResault: NSArray?
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchedResultsController.performFetch(nil)
        fetchedResultsController.delegate = self
        
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Partner")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: "name",
            cacheName: nil)
        
        return fetchedResultsController
        
        }()
    

    @IBAction func loadResaultsTouchUpInside(sender: UIBarButtonItem) {
        var filter = OdataFilter()
        var dataCollection = ODataCollectionManager()
        
        dataCollection.makeRequestToCollection(filter)
        dataCollection._delegate = self
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    
        var secondViewController : PartnerDetailInfo = segue.destinationViewController as! PartnerDetailInfo
        
        var indexPath = tableView.indexPathForSelectedRow() //get index of data for selected row
        
        let partner: AnyObject = fetchedResultsController.objectAtIndexPath(indexPath!)
        
        secondViewController.partner = partner as? Partner
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        performSegueWithIdentifier("segueToDetailView", sender: self)
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "contactCell")
        
        let partner: AnyObject = fetchedResultsController.objectAtIndexPath(indexPath)
        
        cell.textLabel?.text =  partner.name
        
        return cell
        
    }
    
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        
        return fetchedResultsController.sectionForSectionIndexTitle(title, atIndex: index)
        
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
        
        return self.fetchedResultsController.sectionIndexTitles
        
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if let sections = fetchedResultsController.sections {
            
            let sectionInfo = sections[section] as! NSFetchedResultsSectionInfo
            var name = sectionInfo.indexTitle
            
                        
            return sectionInfo.indexTitle
        }
        
        return ""
        

    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        
        return 0
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var rows = 0
        if self.fetchedResultsController.sections!.count > 0 {
            var sectionInfo = self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
            rows = sectionInfo.numberOfObjects
        }
        return rows
    }
    
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        let indexSet = NSIndexSet(index: sectionIndex)
        switch type {
        case NSFetchedResultsChangeType.Insert:
            self.tableView.insertSections(indexSet, withRowAnimation: UITableViewRowAnimation.Fade)
        case NSFetchedResultsChangeType.Delete:
            self.tableView.deleteSections(indexSet, withRowAnimation: UITableViewRowAnimation.Fade)
        case NSFetchedResultsChangeType.Update:
            break
        case NSFetchedResultsChangeType.Move:
            break
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case NSFetchedResultsChangeType.Insert:
             tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case NSFetchedResultsChangeType.Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case NSFetchedResultsChangeType.Update:
            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case NSFetchedResultsChangeType.Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }

    
    
    func requestFailedWithError(error: NSString) {
        
        
    }
    
    func didRecieveResponse(results: NSDictionary) {
        
        
        jsonResault = JSON(results)?[key:"value"] as? NSArray
        
        for var i=0;i<jsonResault?.count; i++ {
            
            var contactJSON = jsonResault?.objectAtIndex(i) as! JSONValue
            let contactInfoJSON = contactJSON[key:"КонтактнаяИнформация"] as? NSArray
            var contactInfoArray = [ContactInfo]()
            let partner = Partner(dictionary: contactJSON as! [String : AnyObject], context: sharedContext)
            CoreDataStackManager.sharedInstance().saveContext()
            if let contactInfoJSON = contactInfoJSON {
                for el in contactInfoJSON {
                    let contactInfo = ContactInfo(dictionary: el as! [String : AnyObject], context: sharedContext)
                    contactInfo.partner = partner
                    CoreDataStackManager.sharedInstance().saveContext()
                    contactInfoArray.append(contactInfo)
                }
            }
            
            //partner.contactInfo = contactInfoArray
            
            CoreDataStackManager.sharedInstance().saveContext()
            
            
            dispatch_async(dispatch_get_main_queue()) {
                
                self.tableView.reloadData()
                
            }
            
        }
    }
    

}
