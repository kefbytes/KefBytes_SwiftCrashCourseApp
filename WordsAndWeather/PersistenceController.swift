//
//  PersistenceController.swift
//  WordsAndWeather
//
//  Created by Franks, Kent on 11/5/15.
//  Copyright © 2016 Franks, Kent. All rights reserved.
//

import CoreData

class PersistenceController {

    fileprivate let privateMoc: NSManagedObjectContext?
    fileprivate(set) var mainMoc: NSManagedObjectContext?				 
    				
    init(completion: @escaping (_ result: Bool, _ failError: NSError?) -> Void) {
            
            let modelURL = Bundle.main.url(forResource: "WordsAndWeather", withExtension: "momd")!
            let mom: NSManagedObjectModel? = NSManagedObjectModel(contentsOf: modelURL)
            /* This is our first chance to fail early. If for some reason our mom failed to be created we want to know asap and not keep going. */
            assert(mom != nil, "Error initializing mom from: \(modelURL)")
            
            let psc: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: mom!)
            /* Here's our second chance to fail early and now we're failing often as well. If psc if nil, no reason to continue. */
            // TODO: Can I change this use guard? Or maybe try! which crashes like an assertion
            assert(psc != nil,"Error initializing psc")
            
            /* Creating and setting up our private moc, notice it gets create on the private queue */
            let localPrivateMoc : NSManagedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
            localPrivateMoc.persistentStoreCoordinator = psc
            privateMoc = localPrivateMoc
            
            /* Check to see if main moc already exists if so we don't want to overwrite it. Again, main moc gets created on the main queue, it will be in sync with our UI */
            if mainMoc == nil {
                let localMainMoc : NSManagedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
                /* we set the parent of the main moc to be the private moc, so any changes and saves will propgate up to the parent and occur there, the main moc does not actually handle any saving, it just funnels up to the private moc which will do the save */
                localMainMoc.parent = privateMoc
                mainMoc = localMainMoc
            } else {
                return
            }
            
            /* we do not know how long it will take to create the store and we don't want to block the UI so we do this on a background queue. */
            let queue = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default)
            queue.async(execute: { () -> Void in
                let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                let storeURL = (urls[urls.endIndex-1]).appendingPathComponent("Data.sqlite")
                
                var error: NSError? = nil
                let storeOptions = [ NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true ]
                do {
                    try psc!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: storeOptions)
                    DispatchQueue.main.async(execute: { () -> Void in
                        /* Again calling back to app delegate */
                        completion(true, nil)
                        return
                    })
                } catch let error1 as NSError {
                    error = error1
                    /* This is where we're calling back to the app delegate and letting it know it can finish any setup */
                    completion(false, error)
                    return
                } catch {
                    fatalError()
                }
            })
        }

     				
    func saveContext(_ completion: (_ result: Bool, _ failError: NSError?) -> Void) {
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
                  		completion(false, error)
                    	return
                 	}
           		}
             	if sMoc.hasChanges {
                	/* We now call the save on the private moc and call the completion block passing whether the save was successful or not and any error info */
                 	do {
                    	try sMoc.save()
                     	completion(true, nil)
                     	return
                	} catch let error1 as NSError {
                 		error = error1
                     	completion(false, error)
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

