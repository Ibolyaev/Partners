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

class ProductsViewController: UITableViewController, NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating,UISearchControllerDelegate {
    
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
        
        
        let fetchRequest = NSFetchRequest(entityName: "Product")
        
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
        
        
    }
    
    
    func loadResaults() {
        loadOdata()
    }
    
    func loadOdata() {
    
        Connection1C.sharedInstance().loadCollection(Product.getCollectionName(), sharedContext: sharedContext) { (result, error) -> Void in
            
            if let error = error {
                self.displayError(error.localizedDescription,titleError: "Failed to load data")
            }else{
                
                Connection1C.sharedInstance().loadCollection(Product.getPicturesCollectionName(), sharedContext: self.sharedContext, completionHandler: { (result, error) -> Void in
                    
                    
                    
                })
                
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.refreshControl?.endRefreshing()
                    self.tableView.reloadData()
                    
                    
                }

            }

            
        }
    }

    // MARK: UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        let fetchRequest = NSFetchRequest(entityName: "Product")
        
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
        
        //performSegueWithIdentifier("segueToDetailView", sender: self)
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        /*var cell = self.tableView.dequeueReusableCellWithIdentifier("PartnerInfoCell", forIndexPath: indexPath) as! PartnerInfoCell
        
        let partner = currentResultsController.objectAtIndexPath(indexPath) as! Partner
        
        cell.titleLabel.text =  partner.name
        
        //need to find out theare is a phone number or email in contact info
        for elementOfcontactInfo in partner.contactInfo {
            switch elementOfcontactInfo.typeContact {
            case ContactInfo.Keys.Telephone:
                //cell.telephoneIcon.highlighted = true
                cell.telephoneIcon.alpha = 1.0
                
            case ContactInfo.Keys.Email:
                //cell.emailIcon.highlighted = true
                cell.emailIcon.alpha = 1.0
            default:
                continue
            }
            
        }
        
        return cell*/
        
        var cell = UITableViewCell()
        
        let product = currentResultsController.objectAtIndexPath(indexPath) as! Product
        
        cell.textLabel!.text =  product.name
        
        cell.imageView?.image = UIImage(data: product.picture)
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