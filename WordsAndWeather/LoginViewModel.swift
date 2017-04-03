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
    static func createLogin(_ userID:String, password:String) -> Bool {
        let defaults = UserDefaults.standard
        defaults.setValue(userID, forKey: Constants.userID)
        defaults.set(true, forKey: Constants.userIDExists)
        return KeychainWrapper.set(Constants.appPassword, value: password)
    }
    
    static func deleteLogin() -> Bool {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: Constants.userID)
        defaults.set(false, forKey: Constants.userIDExists)
        return KeychainWrapper.delete(Constants.appPassword)
    }
    
    static func loginWithUsernamePassword(_ username:String, password:String) -> Bool {
        let defaults = UserDefaults.standard
        let savedUsername = defaults.object(forKey: Constants.userID) as? String
        let savedPassword = KeychainWrapper.get(Constants.appPassword)  as? String
        
        if username.lowercased() == savedUsername!.lowercased() && password == savedPassword {
            return true
        }
        return false
    }
    
    static func loginWithTouchID(_ callBack:@escaping (_ isSuccessful:Bool, _ isTouchIDAvailable:Bool) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = Constants.authenticateWithTouchID
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply:
                {(success: Bool, error: NSError?) in
                    if success {
                        callBack(true, true)
                        print("touchId Login Successful")
                    } else {
                        callBack(false, true)
                    }
            } as! (Bool, Error?) -> Void)
        } else {
            callBack(false, false)
        }
    }
    
    // MARK: - Weather
    
    static func getWeather(_ whenDone: (String) -> Void) {
        
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
    
    static func parseWeatherJSON(_ json: JSON, doneParsing: (String) -> Void) {
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
    
    static func convertKelvin(_ kelvinTemp:Double) -> Double {
        return kelvinTemp * 9/5 - 459.67
    }
    
    
}
