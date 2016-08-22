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

class PartnerDetailInfo: UITableViewController, ABUnknownPersonViewControllerDelegate {

    var partner: Partner?
    var contactInfo: NSArray?
    
    lazy var addressBook: ABAddressBookRef = {
        var error: Unmanaged<CFError>?
        return ABAddressBookCreateWithOptions(nil,
            &error).takeRetainedValue() as ABAddressBookRef
        }()
    
    func unknownPersonViewController(unknownCardViewController: ABUnknownPersonViewController, didResolveToPerson person: ABRecord?) {
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
        
        if section > 0 {
            
            if let partner = partner {
                
                let person = partner.persons[section-1]
                let contactInfoPerson = person.contactInfo as NSArray
               
                return contactInfoPerson.count
            }
        }else{
            if let contactInfo = contactInfo {
                return contactInfo.count
            }
        }
        
        
        return 0
        
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if let partner = partner {
            
            if partner.persons.count != 0 {
                return partner.persons.count + 1
            }
            
        }
        
        return 1
        
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 88.0
        
    }
    

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerCell = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as! HeaderCell
        
        if section > 0 {
            
            if let partner = partner {
                
                let person = partner.persons[section-1]
                headerCell.titleLabel.text = person.name
                headerCell.subTitleLabel.text = person.role
            }
        }else{
           headerCell.titleLabel.text = partner?.name
        
            headerCell.subTitleLabel.text = ""
        }
        
        headerCell.addContact.addTarget(self, action: #selector(PartnerDetailInfo.addContact(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        headerCell.addContact.tag = section
                
        return headerCell
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("ContactInfoCell", forIndexPath: indexPath) as! ContactInfoCell
        return configureContactInfoCell(cell,indexPath: indexPath)
        
    }
    
    func configureContactInfoCell(cell:ContactInfoCell,indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section > 0 {
            
            if let partner = partner {
                
                let person = partner.persons[indexPath.section-1]
                let contactInfoPerson = person.contactInfo as NSArray
                                
                let elementOfcontactInfo = contactInfoPerson.objectAtIndex(indexPath.row) as! ContactInfo
                    
                    switch elementOfcontactInfo.typeContact {
                    case ContactInfo.Keys.Telephone:
                        cell.titleLabel.text = elementOfcontactInfo.telephoneNumber
                        
                        cell.imageViewIcon?.image = UIImage(named: "Phone-32")
                    case ContactInfo.Keys.Email:
                        cell.titleLabel.text = elementOfcontactInfo.info
                        cell.imageViewIcon?.image = UIImage(named: "Message-32")
                    default:
                        cell.titleLabel.text = ""
                    }
                
            }
            
        }else{
            
            if let contactInfo = contactInfo {
                let elementOfcontactInfo = contactInfo.objectAtIndex(indexPath.row) as! ContactInfo
                
                switch elementOfcontactInfo.typeContact {
                case ContactInfo.Keys.Telephone:
                    cell.titleLabel.text = elementOfcontactInfo.telephoneNumber
                    
                    cell.imageViewIcon?.image = UIImage(named: "Phone-32")
                case ContactInfo.Keys.Email:
                    cell.titleLabel.text = elementOfcontactInfo.info
                    cell.imageViewIcon?.image = UIImage(named: "Message-32")
                default:
                    cell.titleLabel.text = ""
                }
                
            }

        }
        
        
        return cell
        
    }
    func createMultiStringRef() -> ABMutableMultiValueRef {
        let propertyType: NSNumber = kABMultiStringPropertyType
        return Unmanaged.fromOpaque(ABMultiValueCreateMutable(propertyType.unsignedIntValue).toOpaque()).takeUnretainedValue() as NSObject as ABMultiValueRef
    }
    func addNewContact(sender:UIButton) {
        
        let abNew = ABUnknownPersonViewController()
        let person: ABRecordRef = ABPersonCreate().takeRetainedValue()
        
        let section = sender.tag
        
        if section == 0 {
            
            if let partner = partner {
                
                let couldSetFirstName = ABRecordSetValue(person,
                    kABPersonFirstNameProperty,
                    partner.name as CFTypeRef,
                    nil)
                fillPersonInfo(person,contactInfo: partner.contactInfo)
                
            }

            
        }else{
            if let partner = partner {
                let personPartner = partner.persons[section-1]
                let couldSetFirstName = ABRecordSetValue(person,
                    kABPersonFirstNameProperty,
                    personPartner.name as CFTypeRef,
                    nil)
                fillPersonInfo(person,contactInfo: personPartner.contactInfo)
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
    
    func fillPersonInfo(person: ABRecordRef,contactInfo:[ContactInfo]) {
        
        for contactInformation in contactInfo {
            
            switch contactInformation.typeContact {
            case ContactInfo.Keys.Telephone:
                let propertyType: NSNumber = kABMultiStringPropertyType
                
                let phoneNumbers: ABMutableMultiValueRef =  createMultiStringRef()
                let phone = ((contactInformation.telephoneNumber).stringByReplacingOccurrencesOfString(" ", withString: "") as NSString)
                
                ABMultiValueAddValueAndLabel(phoneNumbers, phone, kABPersonPhoneMainLabel, nil)
                ABRecordSetValue(person, kABPersonPhoneProperty, phoneNumbers, nil)
                
                
            case ContactInfo.Keys.Email:
                let addr:ABMultiValue = ABMultiValueCreateMutable(
                    ABPropertyType(kABStringPropertyType)).takeRetainedValue()
                ABMultiValueAddValueAndLabel(addr, contactInformation.info, kABHomeLabel, nil)
                ABRecordSetValue(person, kABPersonEmailProperty, addr, nil)
                
            default:
                continue
            }
            
        }

    }
    
    func addContact(sender: UIButton) {
        
        switch ABAddressBookGetAuthorizationStatus(){
        case .Authorized:
            print("Already authorized", terminator: "")
            addNewContact(sender)
        case .Denied:
            print("You are denied access to address book", terminator: "")
            
        case .NotDetermined:
            ABAddressBookRequestAccessWithCompletion(addressBook,
                {granted, error in
                    
                    if granted{
                        print("Access is granted", terminator: "")
                        self.addNewContact(sender)
                    } else {
                        print("Access is not granted", terminator: "")
                    }
                    
            })
        case .Restricted:
            print("Access is restricted", terminator: "")
            
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
            
            let elementOfcontactInfo = contactInfo.objectAtIndex(sender.tag) as! ContactInfo
            callAction(elementOfcontactInfo)
        }
        
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let contactInfo = contactInfo {
            callAction(contactInfo.objectAtIndex(indexPath.row) as! ContactInfo)
        }
        
    }
  
}

