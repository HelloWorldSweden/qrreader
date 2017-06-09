//
// Created by David Wolters on 6/4/17.
// Copyright (c) 2017 David Wolters. All rights reserved.
//

import Foundation

class MobileResponse
{
    
    // Send SMS to some recipients. //
    public static func send(message body : String, to numbers : [String], from sender: String, completion : @escaping (String?) -> Void)
    {
        print("[INFO] MobileResponse Recipients: [\(numbers.joined(separator: ", "))]")
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
        
        // The error that we will be returning (nil if no error). //
        var mrError : String? = nil
        
        // Send the SMS. //
        Request.make(request: .POST, to: Constants.MobileResponse.URLS.SEND_MESSAGE , with: sendParams) { sendError, sendData in

            guard sendError == nil else
            {
                completion(sendError)
                return
            }
            
            do
            {
                // Retrieve the data and validate it. //
                let sendJSON = try JSONSerialization.jsonObject(with: sendData!) as? [String : AnyObject]
                let stringSendData = NSString(data: sendData!, encoding: String.Encoding.ascii.rawValue)
                print("[INFO] MobileResponse Returned (SEND): \(String(describing: stringSendData))")

                guard let unwrappedJSON = sendJSON else
                {
                    mrError = "MobileResponse Error: Error unwrapping JSON Object (SEND): \(String(describing: stringSendData))"
                    print("[ERROR] \(String(describing: mrError))")
                    completion(mrError)
                    return
                }

                guard unwrappedJSON["status"] as! String == "Success" else
                {
                    mrError = "MobileResponse Error: Request returned errors (SEND): \(String(describing: stringSendData))"
                    print("[ERROR] \(String(describing: mrError))")
                    completion(mrError)
                    return
                }

                // Authenticate us. //
                let authParams = [
                        "data" : [
                                "username" : Constants.MobileResponse.API_USERNAME,
                                "password" : Constants.MobileResponse.API_PASSWORD,
                        ]
                ]

                Request.make(request: .POST, to: Constants.MobileResponse.URLS.AUTHENTICATE, with: authParams) { authError, authData in

                    guard authError == nil else
                    {
                        completion(authError)
                        return
                    }


                    
                    do
                    {
                        // Validate AUTH data. //
                        let authJSON = try JSONSerialization.jsonObject(with: authData!) as? [String : Any]
                        let stringAuthData = NSString(data : authData!, encoding: String.Encoding.ascii.rawValue)

                        print("[INFO] MobileResponse Returned (SEND): \(String(describing: stringAuthData))")

                        guard let unwrappedAuthJSON = authJSON else
                        {
                            mrError = "MobileResponse Error: Error whilst unrwapping JSON Object (AUTH): \(String(describing: stringAuthData))"
                            print("[ERROR] \(String(describing: mrError))")
                            completion(mrError)
                            return
                        }

                        guard unwrappedAuthJSON["status"] as? String == "Success" else
                        {
                            mrError = "MobileResponse Error: Request returned errors (AUTH): \(String(describing: stringAuthData))"
                            print("[ERROR] \(String(describing: mrError))")
                            completion(mrError)
                            return
                        }

                        guard let data = unwrappedAuthJSON["data"] as? [String : Any] else
                        {
                            mrError = "MobileResponse Error: Data was not formatted correctly (AUTH): \(String(describing: stringAuthData))"
                            print("[ERROR] \(String(describing: mrError))")
                            completion(mrError)
                            return
                        }

                        guard let token = data["id"] as? String else
                        {
                            mrError = "MobileResponse Error: The data did not contain a token. (AUTH): \(String(describing: stringAuthData))"
                            print("[ERROR] \(String(describing: mrError))")
                            completion(mrError)
                            return
                        }
                        
                        // Check if we are authenticated. //

                        let isAuthParams : [String : Any] = [
                                "data" : [],
                                "authenticationToken" : token
                        ]
                        
                        Request.make(request : .POST, to: Constants.MobileResponse.URLS.IS_AUTHENTICATED, with: isAuthParams) { isAuthError, isAuthData in

                            guard isAuthError == nil else
                            {
                                completion(isAuthError)
                                return
                            }
                            
                            let stringIsAuthData = NSString(data : isAuthData!, encoding: String.Encoding.ascii.rawValue)
                            print("[INFO] MobileResponse Returned (SEND): \(String(describing: stringIsAuthData))")
                            do
                            {
                                // Validate is-auth data. //
                                let isAuthJSON = try JSONSerialization.jsonObject(with: isAuthData!) as? [String : Any]

                                guard let unwrappedIsAuthJSON = isAuthJSON else
                                {
                                    mrError = "MobileResponse Error: Error whilst unwrapping JSON Object (IS_AUTH): \(String(describing: stringIsAuthData))"
                                    print("[ERROR] \(String(describing: mrError))")
                                    completion(mrError)
                                    return
                                }

                                guard unwrappedIsAuthJSON["status"] as? String == "Success" else
                                {
                                    mrError = "MobileResponse Error: Request returned errors (IS_AUTH): \(String(describing: stringIsAuthData))"
                                    print("[ERROR] \(String(describing: mrError))")
                                    completion(mrError)
                                    return
                                }
                                completion(mrError)
                            }
                            catch
                            {
                                mrError = "MobileResponse Error: Catch: \(error.localizedDescription)"
                                print("[ERROR] \(String(describing: mrError))")
                                completion(mrError)
                            }

                        }
                    }
                    catch
                    {
                        mrError = "MobileResponse Error: Request Error: \(error.localizedDescription)"
                        print("[ERROR] \(String(describing: mrError))")
                        completion(mrError)
                    }
                }
            }
            catch
            {
                mrError = "MobileResponse Error: Request Error: \(error.localizedDescription)"
                print("[ERROR] \(String(describing: mrError))")
                completion(mrError)
            }
        }

    }
}
