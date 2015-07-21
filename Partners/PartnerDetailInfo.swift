//
//  PartnerDetailInfo.swift
//  Partners
//
//  Created by Admin on 15.07.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import Foundation
import UIKit
import AddressBookUI

class PartnerDetailInfo: UITableViewController, UITableViewDataSource,UITableViewDelegate,ABUnknownPersonViewControllerDelegate {

    var partner: Partner?
    var contactInfo: NSArray?
    
    lazy var addressBook: ABAddressBookRef = {
        var error: Unmanaged<CFError>?
        return ABAddressBookCreateWithOptions(nil,
            &error).takeRetainedValue() as ABAddressBookRef
        }()
    
    func unknownPersonViewController(unknownCardViewController: ABUnknownPersonViewController!, didResolveToPerson person: ABRecord!) {
        self.navigationController?.popToViewController(self, animated: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        contactInfo = partner!.contactInfo
        
        self.navigationItem.title = partner!.name
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44.0
        tableView.separatorInset = UIEdgeInsetsZero
        
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let contactInfo = contactInfo {
            return contactInfo.count
        }else{
            return 0
        }
        
    }
    

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 88.0
        
    }
    

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let  headerCell = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as! HeaderCell
        
        headerCell.titleLabel.text = partner?.name
        headerCell.addContact.addTarget(self, action: "addContact:", forControlEvents: UIControlEvents.TouchUpInside)
        //headerCell.addconta
        /*switch (section) {
        case 0:
            headerCell.titleLabel.text = partner?.name
            
        default:
            headerCell.headerLabel.text = "Other";
        }*/
        
        return headerCell
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = self.tableView.dequeueReusableCellWithIdentifier("ContactInfoCell", forIndexPath: indexPath) as! ContactInfoCell
        return configureContactInfoCell(cell,indexPath: indexPath)
        
    }
    
    func configureContactInfoCell(cell:ContactInfoCell,indexPath: NSIndexPath) -> UITableViewCell {
        cell.subtitleLabel.text = "testor"
        
        if let contactInfo = contactInfo {
            var elementOfcontactInfo = contactInfo.objectAtIndex(indexPath.row) as! ContactInfo
            
            switch elementOfcontactInfo.typeContact {
            case "Телефон":
                cell.titleLabel.text = elementOfcontactInfo.telephoneNumber
                
                cell.imageViewIcon?.image = UIImage(named: "Phone-32")
            case "АдресЭлектроннойПочты":
                cell.titleLabel.text = elementOfcontactInfo.info
                cell.imageViewIcon?.image = UIImage(named: "Message-32")
            default:
                cell.titleLabel.text = ""
            }
            
        }
        
        return cell
        
    }
    func createMultiStringRef() -> ABMutableMultiValueRef {
        let propertyType: NSNumber = kABMultiStringPropertyType
        return Unmanaged.fromOpaque(ABMultiValueCreateMutable(propertyType.unsignedIntValue).toOpaque()).takeUnretainedValue() as NSObject as ABMultiValueRef
    }
    func addNewContact() {
        
        var abNew = ABUnknownPersonViewController()
        
        let person: ABRecordRef = ABPersonCreate().takeRetainedValue()
        
        let couldSetFirstName = ABRecordSetValue(person,
            kABPersonFirstNameProperty,
            partner?.name as! CFTypeRef,
            nil)
        
        if let partner = partner {
            
            for contactInformation in partner.contactInfo {
                
                switch contactInformation.typeContact {
                case "Телефон":
                    let propertyType: NSNumber = kABMultiStringPropertyType
                    
                    var phoneNumbers: ABMutableMultiValueRef =  createMultiStringRef()
                    var phone = ((contactInformation.telephoneNumber).stringByReplacingOccurrencesOfString(" ", withString: "") as NSString)
                    
                    ABMultiValueAddValueAndLabel(phoneNumbers, phone, kABPersonPhoneMainLabel, nil)
                    ABRecordSetValue(person, kABPersonPhoneProperty, phoneNumbers, nil)

                    
                case "АдресЭлектроннойПочты":
                    let addr:ABMultiValue = ABMultiValueCreateMutable(
                        ABPropertyType(kABStringPropertyType)).takeRetainedValue()
                    ABMultiValueAddValueAndLabel(addr, contactInformation.info, kABHomeLabel, nil)
                    ABRecordSetValue(person, kABPersonEmailProperty, addr, nil)
                    
                default:
                    continue
                }
               
            }
        }
        
        abNew.message = "Create new contact"
        abNew.displayedPerson = person
        abNew.addressBook = self.addressBook
        abNew.allowsActions = false
        abNew.allowsAddingToAddressBook = true
        abNew.unknownPersonViewDelegate = self
        
        self.navigationController?.pushViewController(abNew, animated: true)
        
    }
    
    func addContact(sender: UIButton) {
        
        switch ABAddressBookGetAuthorizationStatus(){
        case .Authorized:
            print("Already authorized")
            addNewContact()
        case .Denied:
            print("You are denied access to address book")
            
        case .NotDetermined:
            ABAddressBookRequestAccessWithCompletion(addressBook,
                {granted, error in
                    
                    if granted{
                        print("Access is granted")
                        self.addNewContact()
                    } else {
                        print("Access is not granted")
                    }
                    
            })
        case .Restricted:
            print("Access is restricted")
            
        }
        
        
    }
    
    func callAction(elementOfcontactInfo:ContactInfo) {
        switch elementOfcontactInfo.typeContact {
        case "Телефон":
            let number = elementOfcontactInfo.telephoneNumber
            
            let phone = "tel://\(number)"
            let url = NSURL(string: phone)
            UIApplication.sharedApplication().openURL(url!)
            
        case "АдресЭлектроннойПочты":
            let email = elementOfcontactInfo.info
            
            let url = NSURL(string: "mailto:\(email)")
            UIApplication.sharedApplication().openURL(url!)
            
            
        default:
            break
        }
        
    }
    
    func actionButton(sender: UIButton) {
        
        if let contactInfo = contactInfo {
            
            var elementOfcontactInfo = contactInfo.objectAtIndex(sender.tag) as! ContactInfo
            callAction(elementOfcontactInfo)
        }
        
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let contactInfo = contactInfo {
            callAction(contactInfo.objectAtIndex(indexPath.row) as! ContactInfo)
        }
        
    }
  
}

