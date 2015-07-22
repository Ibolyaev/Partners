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

class PartnersViewController: UITableViewController, NSFetchedResultsControllerDelegate, ODataCollectionDelegate, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating,UISearchControllerDelegate {
    
    var jsonResault: NSArray?
    var resultSearchController = UISearchController()
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    var searchResultsController: NSFetchedResultsController?
    
    var currentResultsController: NSFetchedResultsController {
        get {
            
            if let searchResultsController  = self.searchResultsController {
                return searchResultsController
            }
            
            return fetchedResultsController
        }
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
    


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchedResultsController.performFetch(nil)
        fetchedResultsController.delegate = self
        
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.delegate = self
            
            self.tableView.tableHeaderView = controller.searchBar
            
            return controller
        })()
        
        var refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector("loadResaults"), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
        
        // Reload the table
        self.tableView.reloadData()

    }
    
    func loadResaults() {
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }

    
    @IBAction func loadResaultsTouchUpInside(sender: UIBarButtonItem) {
        var filter = OdataFilter()
        var dataCollection = ODataCollectionManager()
        
        dataCollection.makeRequestToCollection(filter)
        dataCollection._delegate = self
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        
        var secondViewController : PartnerDetailInfo = segue.destinationViewController as! PartnerDetailInfo
        
        var indexPath = tableView.indexPathForSelectedRow() //get index of data for selected row
        
        let partner: AnyObject = currentResultsController.objectAtIndexPath(indexPath!)
        
        secondViewController.partner = partner as? Partner
        
        resultSearchController.active = false
        
    }

    
    // MARK: UISearchResultsUpdating
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        let fetchRequest = NSFetchRequest(entityName: "Partner")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        let firstNamePredicate = NSPredicate(format: "name CONTAINS[cd] %@", searchController.searchBar.text.lowercaseString)
        
        let predicate = NSCompoundPredicate.orPredicateWithSubpredicates([firstNamePredicate])
        
        fetchRequest.predicate = predicate
        
        searchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        searchResultsController?.performFetch(nil)
        
        self.tableView.reloadData()

    }
    
    // MARK: UISearchControllerDelegate
    
    
    func didDismissSearchController(searchController: UISearchController) {
        searchResultsController = nil
        self.tableView.reloadData()
    }
    
    // MARK: tableView
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        performSegueWithIdentifier("segueToDetailView", sender: self)
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "contactCell")
        
        let partner: AnyObject = currentResultsController.objectAtIndexPath(indexPath)
        
        cell.textLabel?.text =  partner.name
        
        return cell
        
    }
    
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        
        return currentResultsController.sectionForSectionIndexTitle(title, atIndex: index)
        
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
        
        return self.currentResultsController.sectionIndexTitles
        
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if let sections = currentResultsController.sections {
            
            if let sectionInfo = sections[section] as? NSFetchedResultsSectionInfo {
                
                if let name = sectionInfo.name {
                    return sectionInfo.indexTitle
                }
                
            }
            
        }
        
        return ""
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if let sections = currentResultsController.sections {
            return sections.count
        }
        
        return 0
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var rows = 0
        if self.currentResultsController.sections!.count > 0 {
            var sectionInfo = self.currentResultsController.sections![section] as! NSFetchedResultsSectionInfo
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
            
            CoreDataStackManager.sharedInstance().saveContext()
            
            
            dispatch_async(dispatch_get_main_queue()) {
                
                self.tableView.reloadData()
                
            }
            
        }
    }
    
}



