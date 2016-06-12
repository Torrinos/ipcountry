//
//  GetCountryCode.swift
//  ipcountry
//
//  Created by Oleg Medvedev on 2016-06-11.
//  Copyright © 2016 Oleg Medvedev. All rights reserved.
//

import Foundation

func getCountryCode(completionHandler: (countryCode: String, publicIP: String, country: String) -> ()) {
    let apiURL: String = "http://ip-api.com/json"
    
    guard let url = NSURL(string: apiURL) else {
        print("Error: cannot create URL")
        return
    }
    let urlRequest = NSURLRequest(URL: url)
    let config = NSURLSessionConfiguration.defaultSessionConfiguration()
    let session = NSURLSession(configuration: config)
    let task = session.dataTaskWithRequest(urlRequest) {
        (data, response, error) in
        // check for any errors
        guard error == nil else {
            print("Error: GET on http://ip-api.com/json")
            print(error)
            return
        }
        // make sure we got data
        guard let responseData = data else {
            print("Error: did not receive data")
            return
        }
        // parse the result as JSON, since that's what the API provides
        do {
            guard let APIresponse = try NSJSONSerialization.JSONObjectWithData(responseData, options: []) as? [String: AnyObject] else {
                    print("Error: trying to convert data to JSON")
                    return
                }
        
                // check for a countryCode and print it if we have one
                guard let ccCode = APIresponse["countryCode"] as? String else {
                    print("Error: could not get countryCode from JSON")
                    return
                }
            
                // check for a public IP and print it if we have one
                guard let ip = APIresponse["query"] as? String else {
                    print("Error: could not get public IP from JSON")
                    return
                }
            
                // check for a public IP and print it if we have one
                guard let cntry = APIresponse["country"] as? String else {
                    print("Error: could not get country from JSON")
                    return
                }
            
                completionHandler(countryCode: ccCode, publicIP: ip, country: cntry )
            
            } catch  {
                print("Error: parsing JSON")
            }
    }
    task.resume()
}
