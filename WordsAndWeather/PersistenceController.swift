//
//  PersistenceController.swift
//  WordsAndWeather
//
//  Created by Franks, Kent on 11/5/15.
//  Copyright © 2016 Franks, Kent. All rights reserved.
//

import CoreData

class PersistenceController {

    private let privateMoc: NSManagedObjectContext?
    private(set) var mainMoc: NSManagedObjectContext?				 
    				
    init(completion: (result: Bool, failError: NSError?) -> Void) {
            
            let modelURL = NSBundle.mainBundle().URLForResource("WordsAndWeather", withExtension: "momd")!
            let mom: NSManagedObjectModel? = NSManagedObjectModel(contentsOfURL: modelURL)
            /* This is our first chance to fail early. If for some reason our mom failed to be created we want to know asap and not keep going. */
            assert(mom != nil, "Error initializing mom from: \(modelURL)")
            
            let psc: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: mom!)
            /* Here's our second chance to fail early and now we're failing often as well. If psc if nil, no reason to continue. */
            // TODO: Can I change this use guard? Or maybe try! which crashes like an assertion
            assert(psc != nil,"Error initializing psc")
            
            /* Creating and setting up our private moc, notice it gets create on the private queue */
            let localPrivateMoc : NSManagedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
            localPrivateMoc.persistentStoreCoordinator = psc
            privateMoc = localPrivateMoc
            
            /* Check to see if main moc already exists if so we don't want to overwrite it. Again, main moc gets created on the main queue, it will be in sync with our UI */
            if mainMoc == nil {
                let localMainMoc : NSManagedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
                /* we set the parent of the main moc to be the private moc, so any changes and saves will propgate up to the parent and occur there, the main moc does not actually handle any saving, it just funnels up to the private moc which will do the save */
                localMainMoc.parentContext = privateMoc
                mainMoc = localMainMoc
            } else {
                return
            }
            
            /* we do not know how long it will take to create the store and we don't want to block the UI so we do this on a background queue. */
            let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
            dispatch_async(queue, { () -> Void in
                let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
                let storeURL = (urls[urls.endIndex-1]).URLByAppendingPathComponent("Data.sqlite")
                
                var error: NSError? = nil
                let storeOptions = [ NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true ]
                do {
                    try psc!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: storeOptions)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        /* Again calling back to app delegate */
                        completion(result: true, failError: nil)
                        return
                    })
                } catch let error1 as NSError {
                    error = error1
                    /* This is where we're calling back to the app delegate and letting it know it can finish any setup */
                    completion(result: false, failError: error)
                    return
                } catch {
                    fatalError()
                }
            })
        }

     				
    func saveContext(completion: (result: Bool, failError: NSError?) -> Void) {
            var error: NSError? = nil
    	if let sMoc = privateMoc {
    		if let mMoc = mainMoc {
            	if !mMoc.hasChanges && !sMoc.hasChanges {
    				return
            	}
    			if mMoc.hasChanges {
                	/* calling save on the main moc pushes the changes up to the prviate moc. If there are no errors we call the completion block */
                	do {
                    	try mMoc.save()
                 	} catch let error1 as NSError {
                    	error = error1
                  		completion(result: false, failError: error)
                    	return
                 	}
           		}
             	if sMoc.hasChanges {
                	/* We now call the save on the private moc and call the completion block passing whether the save was successful or not and any error info */
                 	do {
                    	try sMoc.save()
                     	completion(result: true, failError: nil)
                     	return
                	} catch let error1 as NSError {
                 		error = error1
                     	completion(result: false, failError: error)
                    	return
                	}
          		}
            } else {
                return
            }
        } else {
        	return
        }
    }
     				

}

