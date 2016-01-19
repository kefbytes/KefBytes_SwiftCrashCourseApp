//
//  Account+CoreDataProperties.swift
//  WordsAndWeather
//
//  Created by Franks, Kent on 11/6/15.
//  Copyright © 2016 Franks, Kent. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Account {

    @NSManaged var accountName: String?
    @NSManaged var password: String?
    @NSManaged var username: String?

}
