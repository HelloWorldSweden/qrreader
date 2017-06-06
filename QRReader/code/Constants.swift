//
//  Constants.swift
//  QRReader
//
//  Created by David Wolters on 6/4/17.
//  Copyright © 2017 David Wolters. All rights reserved.
// let labelGetURL = URL(string : baseURL + "cards/\(cardID)/labels?key=\(key)&token=\(token)")!
// let labelSetURL = URL(string : baseURL + "cards/\(cardID)/labels")!
// var deleteRequest = URLRequest(url: URL(string: "\(self.baseURL)cards/\(cardID)/idLabels/\(labelID)")!)
import Foundation



struct Constants
{
    struct Trello
    {
        
        public static let API_KEY = "0258080a154c252bda276e8dd3c4099a"
        public static let API_TOKEN = "c3deef435c39cb4f384e67fb18f367c2e77ede2293a7b2e1903ce63e22fae3b2"
        
        public class URLS
        {
            public static let BASE = "https://api.trello.com/1"
            
            public static func getLabels(cardID : String) -> String
            {
                return Request.getURLParams(baseUrl: "\(BASE)/cards/\(cardID)/labels", data: ["key" : API_KEY, "token" : API_TOKEN])
            }
            
            public static func setLabel(cardID : String) -> String
            {
                return "\(BASE)/cards/\(cardID)/labels"
            }
            
            public static func deleteLabels(cardID : String, labelID : String) -> String
            {
                return "\(BASE)/cards/\(cardID)/idLabels/\(labelID)"
            }
        }
    }

    class MobileResponse
    {
        public static let API_USERNAME = "info@helloworld.se"
        public static let API_PASSWORD = "Lkv7fdc!"
        public static let SENDER_NAME = "Hello World!"

        public struct URLS
        {
            public static let BASE = "https://api.mobileresponse.se/"
            public static let SEND_MESSAGE = BASE + "quickie/send-message"
            public static let AUTHENTICATE = BASE + "authenticate"
            public static let IS_AUTHENTICATED = BASE + "is-authenticated"
        }

        public static func getMessageBody(loggedIn : Bool, name : String) -> String
        {
            return "Hej!\nDitt barn, \(name) har nu \(loggedIn ? "anlänt till" : "lämnat") lägret!"
        }
    }
}
