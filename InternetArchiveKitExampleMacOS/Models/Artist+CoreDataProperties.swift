//
//  Artist+CoreDataProperties.swift
//  InternetArchiveKitExampleMacOS
//
//  Created by Jason Buckner on 4/5/20.
//  Copyright © 2020 Jason Buckner. All rights reserved.
//
//

import Foundation
import CoreData


extension Artist {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Artist> {
        return NSFetchRequest<Artist>(entityName: "Artist")
    }

    @NSManaged public var identifier: String?
    @NSManaged public var name: String?
    @NSManaged public var recordings: NSSet?

}

// MARK: Generated accessors for recordings
extension Artist {

    @objc(addRecordingsObject:)
    @NSManaged public func addToRecordings(_ value: Recording)

    @objc(removeRecordingsObject:)
    @NSManaged public func removeFromRecordings(_ value: Recording)

    @objc(addRecordings:)
    @NSManaged public func addToRecordings(_ values: NSSet)

    @objc(removeRecordings:)
    @NSManaged public func removeFromRecordings(_ values: NSSet)

}
