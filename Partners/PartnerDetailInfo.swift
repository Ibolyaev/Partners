//
//  PartnerDetailInfo.swift
//  Partners
//
//  Created by Admin on 15.07.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import Foundation
import UIKit

class PartnerDetailInfo: UITableViewController, UITableViewDataSource,UITableViewDelegate {

    var partner: Partner?
    var contactInfo: NSArray?
    
    override func viewWillAppear(animated: Bool) {
        
        contactInfo = partner!.contactInfo
        
        self.navigationItem.title = partner!.name
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let contactInfo = contactInfo {
            return contactInfo.count
        }else{
            return 0
        }
        
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
           var cell = self.tableView.dequeueReusableCellWithIdentifier("PartnerDetailInfoCell", forIndexPath: indexPath) as! PartnerDetailInfoCell
            return configurePartnerCell(cell,indexPath: indexPath)
        }else{
           var cell = self.tableView.dequeueReusableCellWithIdentifier("ContactInfoCell", forIndexPath: indexPath) as! ContactInfoCell
            return configureContactInfoCell(cell,indexPath: indexPath)
        }
        
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            return 88.0
        }else{
            return 44.0
        }
        
    }
    
    func configureContactInfoCell(cell:ContactInfoCell,indexPath: NSIndexPath) -> UITableViewCell {
        cell.subtitleLabel.text = "testor"
        
        
        if let contactInfo = contactInfo {
            var elementOfcontactInfo = contactInfo.objectAtIndex(indexPath.row) as! ContactInfo
            
            switch elementOfcontactInfo.typeContact {
            case "Телефон":
                cell.titleLabel.text = elementOfcontactInfo.telephoneNumber
                
                cell.imageView?.image = UIImage(named: "Phone-32")
            case "АдресЭлектроннойПочты":
                cell.titleLabel.text = elementOfcontactInfo.info
                cell.imageView?.image = UIImage(named: "Message-32")
            default:
                cell.titleLabel.text = ""
            }
            
        }
        
        return cell
        
    }

    func configurePartnerCell(cell:PartnerDetailInfoCell,indexPath: NSIndexPath) -> UITableViewCell {
        
        cell.subtitleLabel.text = "testor"
        
        
        if let contactInfo = contactInfo {
            var elementOfcontactInfo = contactInfo.objectAtIndex(indexPath.row) as! ContactInfo
            cell.partnerLabel.text = elementOfcontactInfo.partner?.name
            
            switch elementOfcontactInfo.typeContact {
            case "Телефон":
                cell.titleLabel.text = elementOfcontactInfo.telephoneNumber
                
                cell.imageViewIcon.image = UIImage(named: "Phone-32")
            case "АдресЭлектроннойПочты":
                cell.titleLabel.text = elementOfcontactInfo.info
                cell.imageViewIcon.image = UIImage(named: "Message-32")
            default:
                cell.titleLabel.text = ""
            }
            
        }
        
        return cell

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

