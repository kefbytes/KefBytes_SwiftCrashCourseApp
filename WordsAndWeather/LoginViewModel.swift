//
//  LoginViewModel.swift
//  SwiftCrashCourseApp
//
//  Created by Franks, Kent on 11/5/15.
//  Copyright © 2015 Franks, Kent. All rights reserved.
//

import Foundation
import KefKeychain
import LocalAuthentication
import SwiftyJSON


class LoginViewModel {
    
    // MARK: - Weather Vars
    static var city:String?
    static var mainWeather:String?
    static var weatherDescription:String?
    static var currentTemp:Int?
    
    // MARK: - Login functions
    static func createLogin(userID:String, password:String) -> Bool {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setValue(userID, forKey: Constants.userID)
        defaults.setBool(true, forKey: Constants.userIDExists)
        return KeychainWrapper.set(Constants.appPassword, value: password)
    }
    
    static func deleteLogin() -> Bool {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey(Constants.userID)
        defaults.setBool(false, forKey: Constants.userIDExists)
        return KeychainWrapper.delete(Constants.appPassword)
    }
    
    static func loginWithUsernamePassword(username:String, password:String) -> Bool {
        let defaults = NSUserDefaults.standardUserDefaults()
        let savedUsername = defaults.objectForKey(Constants.userID) as? String
        let savedPassword = KeychainWrapper.get(Constants.appPassword)  as? String
        
        if username.lowercaseString == savedUsername!.lowercaseString && password == savedPassword {
            return true
        }
        return false
    }
    
    static func loginWithTouchID(callBack:(isSuccessful:Bool, isTouchIDAvailable:Bool) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.DeviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = Constants.authenticateWithTouchID
            context.evaluatePolicy(.DeviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply:
                {(success: Bool, error: NSError?) in
                    if success {
                        callBack(isSuccessful: true, isTouchIDAvailable: true)
                        print("touchId Login Successful")
                    } else {
                        callBack(isSuccessful: false, isTouchIDAvailable: true)
                    }
            })
        } else {
            callBack(isSuccessful: false, isTouchIDAvailable: false)
        }
    }
    
    // MARK: - Weather
    
    static func getWeather(whenDone: (String) -> Void) {
        
//        let url = NSURL(string: "http://api.openweathermap.org/data/2.5/weather?q=charlotte&APPID=b4babdf7c4fc57ccb46e80d1bbf8d6cb")
//        let session = NSURLSession.sharedSession()
//        let dataTask = session.dataTaskWithURL(url!, completionHandler: { (data: NSData?, response:NSURLResponse?,
//            error: NSError?) -> Void in
//            let json = JSON(data: data!)
//            self.parseWeatherJSON(json) {
//                returnedValue -> Void in
//                print(returnedValue)
//                // Calling whenDone within the NSURLSession thread causes issue, need to put on main thread so can update UI
//                dispatch_async(dispatch_get_main_queue(), {
//                    whenDone("Weather Retrieved")
//                })
//            }
//            
//        })
//        dataTask.resume()
    }
    
    static func parseWeatherJSON(json: JSON, doneParsing: (String) -> Void) {
        print("Parsing in process")
        let tempInKelvin = json["main"]["temp"].doubleValue
        self.currentTemp = Int(round(convertKelvin(tempInKelvin)))
        self.city = json["name"].stringValue
        for result in json["weather"].arrayValue {
            self.mainWeather = result["main"].stringValue
            self.weatherDescription = result["description"].stringValue
        }
        doneParsing("Parsing Completed")
    }
    
    static func convertKelvin(kelvinTemp:Double) -> Double {
        return kelvinTemp * 9/5 - 459.67
    }
    
    
}