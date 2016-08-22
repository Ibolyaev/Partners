//
//  ODataParser.swift
//  Demo Jam
//
//  Created by Brenton O'Callaghan on 19/09/2014.
//  Completely open source without any warranty to do with what you like :-)
//

import Foundation
import SwiftyJSON

protocol ODataCollectionDelegate{
    func didRecieveResponse(results: JSON)
    func requestFailedWithError(error: NSString)
}

class ODataCollectionManager: NSObject, NSXMLParserDelegate {
    
    // Temp variable for any received data through the connection.
    internal var _data: NSMutableData = NSMutableData()
    
    // Callback delegate for any oData requests.
    internal var _delegate: ODataCollectionDelegate?
    
    // NSUserDefaults for accessing the stored username and password if required.
    internal var _userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    // oData components
    internal var _collection: NSString = "/Catalog_Партнеры?"
    
    internal var timesOfdidReceiveAuthenticationChallenge: Int = 0
    
    
    // oData query filter
    internal let _formatString: NSString = "$format=json"     // We always use Json for efficiency.
    internal var _filter: OdataFilter = OdataFilter()
    
    func setDelegate(newDelegate:ODataCollectionDelegate){
        self._delegate = newDelegate
    }
    
    func setCollectionName(collectionName:NSString){
        self._collection = collectionName
    }
    
    // Make a request to the configured collection.
    func makeRequestToCollection(filter: OdataFilter) {
                                
        self._filter = filter
        
        let urlString: NSString = self._constructOdataRequestURL().stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
                                
        let url: NSURL = NSURL(string: urlString as String)!
        let request: NSURLRequest = NSURLRequest(URL: url)
        let connection: NSURLConnection = NSURLConnection(request: request, delegate: self,startImmediately: false)!
    
        print("Making request to OData service:  <**censored**> for demojam on stage")
        
    
        connection.start()
    }
    
    // ======================================================================
    // MARK: - Internal/Private Methods
    
    internal func _constructOdataRequestURL() -> NSString{
        
        // FIXME: Change the base URL.
        
        // Always start as the Base URL with the collection and the format string.
        let defaults = NSUserDefaults.standardUserDefaults()
        let address = defaults.stringForKey("address")
        let baseName = defaults.stringForKey("baseName")
        //http://85.236.15.246/Demo_UT/odata/standard.odata/Catalog_%D0%9F%D0%B0%D1%80%D1%82%D0%BD%D0%B5%D1%80%D1%8B
        let baseURL: NSString = "\(address!)/\(baseName!)/odata/standard.odata" + (self._collection as String) + (self._formatString as String)

        
        // Finally we format all the values into the final URL.
        return NSString(format: "%@%@", baseURL, self._filter.getFilterString())
    }
    
    // ======================================================================
    // MARK: - NSURLConnection delegate methods
    
    // Called when the connection fails.
    internal func connection(connection: NSURLConnection!, didFailWithError error: NSError!) {
        print("Failed with error:\(error.localizedDescription)")
        self._delegate?.requestFailedWithError(error.localizedDescription)
    }
    
    // Called when a response is received so we prepare the receiving variables.
    internal func connection(didReceiveResponse: NSURLConnection!, didReceiveResponse response: NSURLResponse!) {
        
        let newResponse: NSHTTPURLResponse = response as! NSHTTPURLResponse
        
        if(newResponse.statusCode != 200){
            didReceiveResponse.cancel()
            self.connection(didReceiveResponse, didFailWithError: NSError(domain: NSHTTPURLResponse.localizedStringForStatusCode(newResponse.statusCode), code: newResponse.statusCode, userInfo: nil))
            return
        }
        
        //New request so we need to clear the data object
        self._data = NSMutableData()
    }
    
    // Called when data is received through the connection.
    internal func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
        //Append incoming data
        self._data.appendData(data)
    }
    
    // Called when the connection finishes - so we prepare and return the response.
    internal func connectionDidFinishLoading(connection: NSURLConnection!) {
        //Finished receiving data and convert it to a JSON object
        //var err: NSError = NSError(
        
        /*let jsonResult: NSDictionary  = (try! NSJSONSerialization.JSONObjectWithData(self._data,
            options:NSJSONReadingOptions.MutableContainers)) as! NSDictionary
        var jsonResult2: NSObject = (try! NSJSONSerialization.JSONObjectWithData(self._data,
            options:NSJSONReadingOptions.MutableContainers)) as! NSObject*/
        
        let jsonResult = JSON(data: self._data)
        
        
        
        // Need to return the result to someone.
        self._delegate?.didRecieveResponse(jsonResult)
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        print("Element's name is \(elementName)")
        print("Element's attributes are \(attributeDict)")
    }
    
    // Called when authentication is required for the oData service.
    internal func connection(connection: NSURLConnection, didReceiveAuthenticationChallenge challenge: NSURLAuthenticationChallenge) {
        
        //didReceiveAuthenticationChallenge always calls if we provide wrong login\pasword 
        // we try to connect 3 times and after that send user a error messege
        self.timesOfdidReceiveAuthenticationChallenge += 1
        // FIXME: Change the default username and password
        /*var username: NSString = "test"
        var password: NSString = "11"*/
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let demoMode = defaults.boolForKey("demoMode")
        
        var username:NSString = ""
        var password:NSString = ""
        
        
        if demoMode  {
            
            username = "test"
            password = "111"
            
        }else{
            
            username = NSString(string: LoginInformation.sharedInstance().login)
            password = NSString(string: LoginInformation.sharedInstance().password)
        }
        
        

        if (username.length == 0 || password.length == 0 || timesOfdidReceiveAuthenticationChallenge > 3)  {
            connection.cancel()
            self._delegate?.requestFailedWithError("You must provide a username and password in the settings app.")
        }
        
        let cred: NSURLCredential = NSURLCredential(user: username as String, password: password as String, persistence: NSURLCredentialPersistence.None)
        
        challenge.sender!.useCredential(cred, forAuthenticationChallenge: challenge)
    }
    
}