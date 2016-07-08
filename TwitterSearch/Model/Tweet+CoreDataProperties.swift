//
//  Tweet+CoreDataProperties.swift
//  TwitterSearch
//
//  Created by Suhit P on 08/07/16.
//  Copyright © 2016 Suhit Patil. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Tweet {

    @NSManaged var id: NSNumber?
    @NSManaged var text: String?
    @NSManaged var user: User?

}
