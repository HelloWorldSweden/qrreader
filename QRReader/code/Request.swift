//
//  Request.swift
//  QRReader
//
//  Created by David Wolters on 5/31/17.
//  Copyright © 2017 David Wolters. All rights reserved.
//

import Foundation


class Request
{
    
    // Make a request to a url without data. //
    public static func make(request requestType : RequestType, to url : String, completion: @escaping (String?, Data?) -> Void)
    {
        make(request: requestType, to: url, with: nil, completion: completion)
    }
    
    // Make a request to a url with data. //
    public static func make(request requestType : RequestType, to stringURL : String, with data : [String : Any]?, completion: @escaping (String?, Data?) -> Void)
    {
        print("[INFO] Making a request to: \"\(stringURL)\"")
        // First, let's create the URL that we will use to send the request to. This is simply the base URL (https://api.trello.com/1/) + the url provided by the parmeter //
        let url = URL(string: stringURL)!
        
        // Then let's create the request that we will use to make a request to the Trello server. //
        var request = URLRequest(url: url)
        
        // Set the TYPE of the request to the one specified (GET, POST, or DELETE). //
        request.httpMethod = requestType.rawValue

        // This is the error variable which we will return in case of error.  (set it to nothing at the start, since we have no errors yet!) //
        var requestError : String? = nil
        
        // If we have supplied data, let's add it to the request! //
        if let unwrappedData = data
        {
            // Try to cast the data to a JSON Object that can be sent with the request. //
            let jsonData = try? JSONSerialization.data(withJSONObject: unwrappedData)
            
            // Make sure that the cast was successfull. //
            guard let _ = jsonData else
            {
                requestError = "Casting the data provided into a JSON Object was not successfull!"
                print("[ERROR] \(String(describing: requestError!))")
                completion(requestError, nil)
                return
            }
            
            request.httpBody = jsonData!
            
            
            // If our request type is either POST or DELETE, and we have data, let's set the appropriate header fields. //
            if requestType == .POST || requestType == .DELETE
            {
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
            }
        }
        
        // Now, let's make the request. //
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            // Make sure there are no errors. //
            guard error == nil else
            {
                requestError = "There was an error whilst making the request: \(String(describing: error!.localizedDescription))"
                print("[ERROR] \(String(describing: requestError!))")
                completion(requestError, nil)
                return
            }
            
            // Make sure that data was returned. //
            guard let data = data else
            {
                requestError = "No data was returned."
                print("[ERROR] \(String(describing: requestError!))")
                completion(requestError, nil)
                return
            }
            
            completion(requestError, data)
        }
        task.resume()


    }

    
    public static func getURLParams(baseUrl : String, data : [String : Any]) -> String
    {
        var completeUrl = baseUrl + (baseUrl.contains("?") ? "" : "?")
        
        for (key, value) in data {

            completeUrl += "\(key)=\(value)&"
        }
        
        let index = completeUrl.index(before: completeUrl.endIndex)
        completeUrl = completeUrl.substring(to: index)
        
        return completeUrl
        
        
    }
}
