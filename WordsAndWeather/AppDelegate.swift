//
//  AppDelegate.swift
//  WordsAndWeather
//
//  Created by Franks, Kent on 11/5/15.
//  Copyright © 2016 Franks, Kent. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    /* Create an instance of PersistenceController which has a private setter (so that it is only created by us and an internal(default value) getter. */
    private(set) var persistenceController: PersistenceController? = nil
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        /* We are creating the persistenceController with a trailing closure which acts like a callback block allowing us to wait until completion before completing any setup */
        persistenceController = PersistenceController(){
            (response) -> Void in
            // Check for response and complete setup
            self.completeAnySetup()
        }
        
        /* This is where we're using injection to pass the persistenceController to the viewController. You don't want to be getting it from the AppDelegate with something like this;
        let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
        var managedObjectContext = appDelegate.managedObjectContext?
        */
        let viewController: LoginViewController = self.window!.rootViewController as! LoginViewController
        viewController.persistenceController = persistenceController
        
        return true
    }
    
    func completeAnySetup () {
        // Complete any setup
    }
    
}

