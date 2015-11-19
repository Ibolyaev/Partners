//
//  ProductsViewController.swift
//  Partners
//
//  Created by Admin on 30.07.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import Foundation
import Foundation
import UIKit
import CoreData

class OrdersViewController: UITableViewController, NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating,UISearchControllerDelegate {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var resultSearchController = UISearchController()
    
    var indicator = UIActivityIndicatorView()
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
        
        
        let fetchRequest = NSFetchRequest(entityName: "Order")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: "date",
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
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }

        
    }
    
    
    func loadResaults() {
        loadOdata()
    }
    
    func loadOdata() {
        
        Connection1C.sharedInstance().loadCollection(Order.getCollectionName(), sharedContext: sharedContext) { (result, error) -> Void in
            
            if let error = error {
                self.displayError(error.localizedDescription,titleError: "Failed to load data")
            }else{
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.refreshControl?.endRefreshing()
                    self.tableView.reloadData()
                    
                    
                }
            }
        }
    }
    
    // MARK: UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        let fetchRequest = NSFetchRequest(entityName: "Order")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "number", ascending: true)]
        
        let firstNamePredicate = NSPredicate(format: "number CONTAINS[cd] %@", searchController.searchBar.text.lowercaseString)
        
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
        
        //performSegueWithIdentifier("segueToDetailView", sender: self)
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: AnyObject = self.tableView.dequeueReusableCellWithIdentifier("OrderInfoCell", forIndexPath: indexPath)
        
        let order = currentResultsController.objectAtIndexPath(indexPath) as! Order
        
        cell.textLabel!!.text =  order.number
        cell.detailTextLabel?!.text = order.totalSum.stringValue
        
        
        return cell
            as! UITableViewCell
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
                    
                    /*var dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "hh:mm" //format style. Browse online to get a format that fits your needs.
                    var dateString = dateFormatter.stringFromDate(date)*/
                    var dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd' 'hh:mm:ss '+0000'" //format style. Browse online to get a format that fits your needs.
                    var date = dateFormatter.dateFromString(name)!
                    
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    var dateString = dateFormatter.stringFromDate(date)
                    
                    return dateString
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
    func displayError(errorString: String?,titleError: String?) {
        dispatch_async(dispatch_get_main_queue(), {
            if let errorString = errorString {
                
                let alertController = UIAlertController(title: titleError, message: "\(errorString)", preferredStyle: .Alert)
                
                
                let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                    // ...
                }
                alertController.addAction(OKAction)
                
                self.presentViewController(alertController, animated: true) {
                    // ...
                }
            }
        })
    }
    
    
}