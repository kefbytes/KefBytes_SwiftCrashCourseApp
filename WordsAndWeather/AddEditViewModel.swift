//
//  AddEditViewModel.swift
//  SwiftCrashCourseApp
//
//  Created by Franks, Kent on 11/5/15.
//  Copyright © 2015 Franks, Kent. All rights reserved.
//

import Foundation
import CoreData

class AddEditViewModel {
    
    static func saveAccount(mainContext:NSManagedObjectContext?, coreDataController:PersistenceController?, accountName:String, userName:String, password:String) {
        if let mainContext = mainContext {
            /* We use our mainContext to instantiate the managedObject, as we make changes to the mo they will be saved in the mainContext */
            let entityDescription = NSEntityDescription.entityForName("Account", inManagedObjectContext: mainContext)
            let account = Account(entity: entityDescription!, insertIntoManagedObjectContext: mainContext)
            account.accountName = accountName
            account.username = userName
            account.password = password
            
            if let coreDataController = coreDataController {
                coreDataController.saveContext({
                    (response, error) -> Void in
                    let fetchRequest = NSFetchRequest(entityName:"Account")
                    do {
                        if let _ = try mainContext.executeFetchRequest(fetchRequest) as? [Account] {
                            print("save completed:\(response)")
                        }
                    } catch {
                        print("Error fetching results")
                    }
                })
            }
        }
    }
    
    static func updateAccount(mainContext:NSManagedObjectContext?, coreDataController:PersistenceController?, accountName:String, userName:String, password:String) {
        let fetchRequest = NSFetchRequest(entityName: "Account")
        let accountnamePredicate = NSPredicate(format: "accountName == %@", accountName)
        fetchRequest.predicate = accountnamePredicate
        do {
            let accounts = try mainContext!.executeFetchRequest(fetchRequest) as? [Account]
            let account = accounts![0]
            account.username = userName
            account.password = password
            if let coreDataController = coreDataController {
                coreDataController.saveContext({
                    (response, error) -> Void in
                })
            }
        }
        catch {
            print("Fetch failed")
        }
    }
    
    
}

