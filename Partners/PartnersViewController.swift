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
import SwiftyJSON

class PartnersViewController: UITableViewController, NSFetchedResultsControllerDelegate, ODataCollectionDelegate, UISearchResultsUpdating,UISearchControllerDelegate {
    
    var jsonResault: NSArray?
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
        
        do {
            try fetchedResultsController.performFetch()
        } catch _ {
        }
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
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(PartnersViewController.loadResaults), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
        
        
    }
    
    func loadResaults() {
        loadOdata()
    }
    
    func loadOdata() {
        
        let filter = OdataFilter()
        filter.addFilter("DeletionMark", filterValue: "false", filterOperand: "eq", clauseOperand: "")
        
        let dataCollection = ODataCollectionManager()
        
        dataCollection.setCollectionName(Partner.getCollectionName())
        
        dataCollection.makeRequestToCollection(filter)
                
        dataCollection._delegate = self
    }

    
    
    @IBAction func settingsTouch(sender: UIBarButtonItem) {
        
        let ViewController = self.storyboard!.instantiateViewControllerWithIdentifier("SettingsViewController") as! SettingsViewController
        presentViewController(ViewController, animated: true, completion: nil)
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let secondViewController : PartnerDetailInfo = segue.destinationViewController as! PartnerDetailInfo
        
        let indexPath = tableView.indexPathForSelectedRow //get index of data for selected row
        
        let partner: AnyObject = currentResultsController.objectAtIndexPath(indexPath!)
        
        secondViewController.partner = partner as? Partner
        
        resultSearchController.active = false
        
    }

    
    // MARK: UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        let fetchRequest = NSFetchRequest(entityName: "Partner")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        let firstNamePredicate = NSPredicate(format: "name CONTAINS[cd] %@", searchController.searchBar.text!.lowercaseString)
        
        let predicate = NSCompoundPredicate.init(andPredicateWithSubpredicates: [firstNamePredicate])
        
        fetchRequest.predicate = predicate
        
        searchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try searchResultsController?.performFetch()
        } catch _ {
        }
        
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
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("PartnerInfoCell", forIndexPath: indexPath) as! PartnerInfoCell
        
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
        
        return cell
        
    }
    
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        
        return currentResultsController.sectionForSectionIndexTitle(title, atIndex: index)
        
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        
        return self.currentResultsController.sectionIndexTitles
        
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if let sections = currentResultsController.sections {
            
            if let sectionInfo = sections[section] as? NSFetchedResultsSectionInfo {
                
                return sectionInfo.indexTitle
                
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
            let sectionInfo = self.currentResultsController.sections![section] 
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
        
        if error == "You must provide a username and password in the settings app." {
            var loginTextField: UITextField?
            var passwordTextField: UITextField?
            let alertController = UIAlertController(title: "Wrong password or login", message: "You must provide a username and password", preferredStyle: .Alert)
            let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
                print("Ok Button Pressed")
                if let login = loginTextField?.text {
                   LoginInformation.sharedInstance().login = login
                }
                if let password = passwordTextField?.text {
                   LoginInformation.sharedInstance().password = password
                }
                
                self.loadResaults()
            })
            let cancel = UIAlertAction(title: "Cancel", style: .Cancel) { (action) -> Void in
                print("Cancel Button Pressed")
                self.refreshControl?.endRefreshing()
            }
            alertController.addAction(ok)
            alertController.addAction(cancel)
            alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
                // Enter the textfiled customization code here.
                loginTextField = textField
                loginTextField?.placeholder = "Login"
            }
            alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
                // Enter the textfiled customization code here.
                passwordTextField = textField
                passwordTextField?.placeholder = "Password"
                passwordTextField?.secureTextEntry = true
            }
            
            presentViewController(alertController, animated: true, completion: nil)
        }else{
           
            displayError("Failed to load data", titleError: error as String)
            self.refreshControl?.endRefreshing()
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

    
    func didRecieveResponse(results: JSON) {
        
        print("didRecieveResponse")
        //print(results)
        
        let jsonResault = results["value"].array
        let odataMetadata = results["odata.metadata"].string
        
        var odataType = ""
        
        if let odataMetadata = odataMetadata {
            
            let string = odataMetadata as String
            
            let needle: Character = "#"
            if let idx = string.characters.indexOf(needle) {
                let pos = string.startIndex.distanceTo(idx)
                
                odataType = string.substringFromIndex(string.startIndex.advancedBy(pos+1))
                
            }
            else {
                displayError("Unkown data type: \(odataType)", titleError: "Failed to load data")
                
            }
        }else{
            displayError("Unkown data type: \(odataType)", titleError: "Failed to load data")
            
        }
        print("\(odataType)")
        
        
        if Partner.getCollectionName() == "/\(odataType)?" {
            loadPartnersInfo(jsonResault!)
            
            dispatch_async(dispatch_get_main_queue()) {
                CoreDataStackManager.sharedInstance().saveContext()
                //we need to download persons info after we load partners
                let filter = OdataFilter()
                let dataCollection = ODataCollectionManager()
                dataCollection.setCollectionName(Person.getCollectionName())
                
                dataCollection.makeRequestToCollection(filter)
                
                dataCollection._delegate = self

                
            }

            
        }
        
        if Person.getCollectionName() == "/\(odataType)?" {
            loadPersonsInfo(jsonResault!)
            self.refreshControl?.endRefreshing()
                        
            dispatch_async(dispatch_get_main_queue()) {
                
                self.tableView.reloadData()
                
            }
            
        }
        
    }


    func loadPartnersInfo(jsonResault:[JSON]) {
        
        for i in 0 ..< jsonResault.count {
            let contactJSON = jsonResault[i]
            
            let partner = Partner.loadUpdateInfo(contactJSON, context: sharedContext)
           
            let contactInfoJSON = contactJSON[ContactInfo.Keys.ContactInfoText].array
            
            if let _contactInfoJSON = contactInfoJSON {
                ContactInfo.loadUpdateInfoPartner(partner, contactInfoJSON: _contactInfoJSON, context: sharedContext)
                CoreDataStackManager.sharedInstance().saveContext()
            }
            
            
           
            
            
            
        }
    }
    
    func loadPersonsInfo(jsonResault:[JSON]) {
        for i in 0 ..< jsonResault.count {
            let contactJSON = jsonResault[i]
            
            let contactInfoJSON = contactJSON[ContactInfo.Keys.ContactInfoText].array
            
            let person = Person.loadUpdateInfo(contactJSON, context: sharedContext)
            
            ContactInfo.loadUpdateInfoPerson(person, contactInfoJSON: contactInfoJSON, context: sharedContext)
            CoreDataStackManager.sharedInstance().saveContext()
        }
        
    }
}
    




