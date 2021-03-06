//
//  User+CoreDataProperties.swift
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

extension User {

    @NSManaged var name: String?
    @NSManaged var profileImageUrl: String?
    @NSManaged var screenName: String?

}
