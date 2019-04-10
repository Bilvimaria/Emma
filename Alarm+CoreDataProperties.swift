//
//  Alarm+CoreDataProperties.swift
//  Emma
//
//  Created by Bilvi Maria Joseph on 2019-03-23.
//  Copyright © 2019 Bilvi Maria Joseph. All rights reserved.
//
//

import Foundation
import CoreData


extension Alarm {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Alarm> {
        return NSFetchRequest<Alarm>(entityName: "Alarm")
    }

    @NSManaged public var isOn: String?

}
