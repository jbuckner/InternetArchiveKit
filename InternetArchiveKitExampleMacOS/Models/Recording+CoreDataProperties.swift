//
//  Recording+CoreDataProperties.swift
//  InternetArchiveKitExampleMacOS
//
//  Created by Jason Buckner on 4/5/20.
//  Copyright © 2020 Jason Buckner. All rights reserved.
//
//

import Foundation
import CoreData


extension Recording {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Recording> {
        return NSFetchRequest<Recording>(entityName: "Recording")
    }

    @NSManaged public var date: Date?
    @NSManaged public var identifier: String?
    @NSManaged public var venue: String?
    @NSManaged public var artist: Artist?

}
