//
//  SettingsViewController.swift
//  Partners
//
//  Created by Admin on 22.07.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import Foundation
import UIKit


class SettingsViewController: UIViewController {
    
   
    
    @IBOutlet weak var addresstextField: UITextField!
    @IBOutlet weak var baseNameTextField: UITextField!
    
    override func viewWillAppear(animated: Bool) {
        addresstextField.text = "http://"
    }
    
    @IBAction func connectTouchUpInside(sender: UIButton) {
        
        if verifyUrl(addresstextField.text) {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(addresstextField.text, forKey: "address")
            defaults.setObject(baseNameTextField.text, forKey: "baseName")
            defaults.setObject(false, forKey: "demoMode")
        }
        
    }
    
    
    @IBAction func demoTouchUpInside(sender: UIButton) {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject("http://85.236.15.246", forKey: "address")
        defaults.setObject("Demo_UT", forKey: "baseName")
        defaults.setObject(true, forKey: "demoMode")
        
    }
    func fileExists(url : NSURL!) -> Bool {
        
        let req = NSMutableURLRequest(URL: url)
        req.HTTPMethod = "HEAD"
        req.timeoutInterval = 1.0 // Adjust to your needs
        
        var response : NSURLResponse?
        NSURLConnection.sendSynchronousRequest(req, returningResponse: &response, error: nil)
        
        return ((response as? NSHTTPURLResponse)?.statusCode ?? -1) == 200
    }
    func verifyUrl (urlString: String?) -> Bool {
        //Check for nil
        if let urlString = urlString {
            // create NSURL instance
            if let url = NSURL(string: urlString) {
                // check if your application can open the NSURL instance
                return fileExists(url)
            }
        }
        return false
    }
    
}
