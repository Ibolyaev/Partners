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

    var contactJSON: JSONValue!
    var contactInfo: NSArray?
    
    override func viewWillAppear(animated: Bool) {
        
        contactInfo = contactJSON?[key:"КонтактнаяИнформация"] as? NSArray
        
        self.navigationItem.title = contactJSON[key:"Description"] as! NSString as String
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let contactInfo = contactInfo {
            return contactInfo.count
        }else{
            return 0
        }
        
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = self.tableView.dequeueReusableCellWithIdentifier("PartnerDetailInfoCell", forIndexPath: indexPath) as! PartnerDetailInfoCell
        
        cell.actionButton.tag = indexPath.row;
        cell.actionButton.addTarget(self, action: "actionButton:", forControlEvents: .TouchUpInside)
        
        
        
        if let contactInfo = contactInfo {
            var a = contactInfo.objectAtIndex(indexPath.row) as! JSONValue
            //[11]	(null)	@"Тип" : @"Телефон"
            if let contactType = a[key:"Тип"] as? String {
                
                switch contactType {
                case "Телефон":
                    cell.titleLabel.text = a[key:"НомерТелефона"] as? String
                    
                    cell.actionButton.setImage(UIImage(named: "Phone-32"), forState: UIControlState.Normal)
                case "АдресЭлектроннойПочты":
                    cell.titleLabel.text = a[key:"Представление"] as? String
                    cell.actionButton.setImage(UIImage(named: "Message-32"), forState: UIControlState.Normal)
                default:
                    cell.titleLabel.text = ""
                }

                
            }
            
            
        }
        
        return cell
        
    }
    
    func actionButton(sender: UIButton) {
        
        
        if let contactInfo = contactInfo {
            let info = contactInfo.objectAtIndex(sender.tag) as! JSONValue
            
            if let contactType = info[key:"Тип"] as? String {
                
                switch contactType {
                case "Телефон":
                    let number = info[key:"НомерТелефона"] as? String
                    if let number = number {
                        let phone = "tel://\(number)"
                        let url = NSURL(string: phone)
                        UIApplication.sharedApplication().openURL(url!)
                    }
                    
                case "АдресЭлектроннойПочты":
                    let email = info[key:"Представление"] as? String
                    if let email = email {
                        let url = NSURL(string: "mailto:\(email)")
                        UIApplication.sharedApplication().openURL(url!)
                    }
                    
                default:
                    return
                }
                
                
            }
            
            
        }

        
        
    }


}

