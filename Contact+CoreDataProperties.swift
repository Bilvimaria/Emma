//
//  Contact+CoreDataProperties.swift
//  Emma
//
//  Created by Bilvi Maria Joseph on 2019-03-20.
//  Copyright © 2019 Bilvi Maria Joseph. All rights reserved.
//
//

import Foundation
import CoreData


extension Contact {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Contact> {
        return NSFetchRequest<Contact>(entityName: "Contact")
    }

    @NSManaged public var name: String?
    @NSManaged public var phoneNumber: String?

}
