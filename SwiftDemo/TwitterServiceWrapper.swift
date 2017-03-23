//
//  Authenticator.swift
//  SwiftDemo
//
//  Created by Shivani Ashra on 22/03/17.
//  Copyright (c) 2017 Shivani Ashra. All rights reserved.
//

import Foundation

protocol TwitterFeedDelegate{
    func finishedDownloading(model:TwitterFeedModel)
}

public class TwitterServiceWrapper:NSObject {
    
    var delegate:TwitterFeedDelegate?
    
    let consumerKey = "Fw0Impt1dIhZLKqjNL798KV7q"
    let consumerSecret = "KAS6GplSvz1k8ETiDF3j1WeEpV9wCRCPbxXqZY3L6aQU48KhNs"
    let host = "api.twitter.com"
    
    // MARK:- Bearer Token
    func getBearerToken(completion:(bearerToken: String) ->Void) {
        
        let components = NSURLComponents() 
        components.scheme = "https";
        components.host = self.host
        components.path = "/oauth2/token";
        
        let url = components.URL;
        
        let request = NSMutableURLRequest(URL:url!)
        
        request.HTTPMethod = "POST"
        request.addValue("Basic " + getBase64EncodeString(), forHTTPHeaderField: "Authorization")
        request.addValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        let grantType =  "grant_type=client_credentials"
        
        request.HTTPBody = grantType.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        NSURLSession.sharedSession() .dataTaskWithRequest(request, completionHandler: { (data: NSData?, response:NSURLResponse?, error: NSError?) -> Void in
            
            do {
                if let results: NSDictionary = try NSJSONSerialization .JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments  ) as? NSDictionary {
                    if let token = results["access_token"] as? String {
                        completion(bearerToken: token)
                    } else {
                        print(results["errors"])
                    }
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }).resume()
        
    }
    
    
    // MARK:- base64Encode String
    
    func getBase64EncodeString() -> String {
        
        let consumerKeyRFC1738 = consumerKey.stringByAddingPercentEncodingWithAllowedCharacters( NSCharacterSet.URLQueryAllowedCharacterSet())
        
        let consumerSecretRFC1738 = consumerSecret.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        
        let concatenateKeyAndSecret = consumerKeyRFC1738! + ":" + consumerSecretRFC1738!
        
        let secretAndKeyData = concatenateKeyAndSecret.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)
        
        let base64EncodeKeyAndSecret = secretAndKeyData?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
        
        return base64EncodeKeyAndSecret!
    }
    
    // MARK:- Service Call
    
    func getResponseForRequest(url:String) {
        
        getBearerToken({ (bearerToken) -> Void in
            
            let request = NSMutableURLRequest(URL: NSURL(string: url)!)
            request.HTTPMethod = "GET"
            
            let token = "Bearer " + bearerToken
            
            request.addValue(token, forHTTPHeaderField: "Authorization")
            
            NSURLSession.sharedSession() .dataTaskWithRequest(request, completionHandler: { (data: NSData?, response:NSURLResponse?, error: NSError?) -> Void in
                
                self.processResult(data!, response: response!, error: error)
                
            }).resume()
        })
        
    }
    
    // MARK:- Process results
    
    func processResult(data: NSData, response:NSURLResponse, error: NSError?) {
        
        do {
            
            if let results: NSDictionary = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSDictionary {
                
                if let users = results["statuses"] as? NSMutableArray {
                    for user in users {
                        let userInfoObj = user["user"] as? NSDictionary
                        let profileImageUrl = userInfoObj!["profile_image_url_https"] as! String
                        let follower = TwitterFeedModel(name: user["text"] as! String, url: profileImageUrl)
                        self.delegate?.finishedDownloading(follower)
                    }
                    
                } else {
                    print(results["errors"])
                }
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
}