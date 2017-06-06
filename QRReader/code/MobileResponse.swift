//
// Created by David Wolters on 6/4/17.
// Copyright (c) 2017 David Wolters. All rights reserved.
//

import Foundation

class MobileResponse
{
    
    // Send SMS to some recipients. //
    public static func send(message body : String, to numbers : [String], from sender: String)
    {
        // The parameters for sending the request
        let sendParams = [
                "data" : [
                        "username"      : Constants.MobileResponse.API_USERNAME,
                        "password"      : Constants.MobileResponse.API_PASSWORD,
                        "recipients"    : numbers,
                        "message"       : body,
                        "senderName"    : sender,
                ]

        ]
        
        // Send the SMS. //
        Request.make(request: .POST, to: Constants.MobileResponse.URLS.SEND_MESSAGE , with: sendParams) { sendData in

            do
            {
                // Retrieve the data and validate it. //
                let sendJSON = try JSONSerialization.jsonObject(with: sendData) as? [String : AnyObject]
                let stringSendData = NSString(data: sendData, encoding: String.Encoding.ascii.rawValue)

                guard let unwrappedJSON = sendJSON else
                {
                    print("[ERROR] MobileResponse Error: Error unwrapping JSON Object (SEND): \(stringSendData)")
                    return
                }

                guard unwrappedJSON["status"] as! String == "Success" else
                {
                    print("[ERROR] MobileResponse Error: Request returned errors (SEND): \(stringSendData)")
                    return
                }

                // Authenticate us. //
                let authParams = [
                        "data" : [
                                "username" : Constants.MobileResponse.API_USERNAME,
                                "password" : Constants.MobileResponse.API_PASSWORD,
                        ]
                ]

                Request.make(request: .POST, to: Constants.MobileResponse.URLS.AUTHENTICATE, with: authParams) { authData in

                    do
                    {
                        // Validate AUTH data. //
                        let authJSON = try JSONSerialization.jsonObject(with: authData) as? [String : Any]
                        let stringAuthData = NSString(data : authData, encoding: String.Encoding.ascii.rawValue)

                        guard let unwrappedAuthJSON = authJSON else
                        {
                            print("[ERROR] MobileResponse Error: Error whilst unrwapping JSON Object (AUTH): \(stringAuthData)")
                            return
                        }

                        guard unwrappedAuthJSON["status"] as? String == "Success" else
                        {
                            print("[ERROR] MobileResponse Error: Request returned errors (AUTH): \(stringAuthData)")
                            return
                        }

                        guard let data = unwrappedAuthJSON["data"] as? [String : Any] else
                        {
                            print("[ERROR] MobileResponse Error: Data was not formatted correctly (AUTH): \(stringAuthData)")
                            return
                        }

                        guard let token = data["id"] as? String else
                        {
                            print("[ERROR] MobileResponse Error: The data did not contain a token. (AUTH): \(stringAuthData)")
                            return
                        }
                        
                        // Check if we are authenticated. //

                        let isAuthParams : [String : Any] = [
                                "data" : [],
                                "authenticationToken" : token
                        ]
                        
                        Request.make(request : .POST, to: Constants.MobileResponse.URLS.IS_AUTHENTICATED, with: isAuthParams) { isAuthData in

                            let stringIsAuthData = NSString(data : isAuthData, encoding: String.Encoding.ascii.rawValue)

                            do
                            {
                                // Validate is-auth data. //
                                let isAuthJSON = try JSONSerialization.jsonObject(with: isAuthData) as? [String : Any]

                                guard let unwrappedIsAuthJSON = isAuthJSON else
                                {
                                    print("[ERROR] MobileResponse Error: Error whilst unwrapping JSON Object (IS_AUTH): \(stringIsAuthData)")
                                    return
                                }

                                guard unwrappedIsAuthJSON["status"] as? String == "Success" else
                                {
                                    print("[ERROR] MobileResponse Error: Request returned errors (IS_AUTH): \(stringIsAuthData)")
                                    return
                                }
                                print("[INFO] MobileResponse: SUCCESS")
                            }
                            catch
                            {
                                print("[ERROR] Catch: \(error.localizedDescription)")
                            }

                        }
                    }
                    catch
                    {
                        print("[ERROR] MobileResponse Error: Request Error: \(error.localizedDescription)")
                    }



                }
            }
            catch
            {
                print("[ERROR] MobileResponse Error: Request Error: \(error.localizedDescription)")
            }


            
        }
    }
}
