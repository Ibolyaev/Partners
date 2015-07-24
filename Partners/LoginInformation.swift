//
//  LoginInformation.swift
//  Partners
//
//  Created by Admin on 23.07.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

import Foundation

class LoginInformation: NSObject {
    var login:String = ""
    var password:String = ""
    // MARK: - Shared Instance
    
    class func sharedInstance() -> LoginInformation {
        
        struct Singleton {
            static var sharedInstance = LoginInformation()
        }
        
        return Singleton.sharedInstance
    }

    
    
}