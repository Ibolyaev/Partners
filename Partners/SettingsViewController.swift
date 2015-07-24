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
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(addresstextField.text, forKey: "address")
        defaults.setObject(baseNameTextField.text, forKey: "baseName")
        defaults.setObject(false, forKey: "demoMode")
    }
    
    
    @IBAction func demoTouchUpInside(sender: UIButton) {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject("http://85.236.15.246", forKey: "address")
        defaults.setObject("Demo_UT", forKey: "baseName")
        defaults.setObject(true, forKey: "demoMode")
        
    }
    
}
