//
//  ClipboardEntity+CoreDataProperties.swift
//  Paste
//
//  Created by 金楠翔 on 2023/10/8.
//
//

import Foundation
import CoreData


extension ClipboardEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ClipboardEntity> {
        return NSFetchRequest<ClipboardEntity>(entityName: "ClipboardEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var appName: String?
    @NSManaged public var timestamp: Double
    @NSManaged public var content: String?
    @NSManaged public var appIconURL: String?
    @NSManaged public var type: String?
    @NSManaged public var sizeInBytes: Int64

}

extension ClipboardEntity : Identifiable {

}
