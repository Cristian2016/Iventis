//
//  DSBPair+CoreDataProperties.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 12.07.2022.
//
//

import Foundation
import CoreData


extension DSBPair {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DSBPair> {
        return NSFetchRequest<DSBPair>(entityName: "DSBPair")
    }

    @NSManaged public var start: Date?
    @NSManaged public var pause: Date?
    @NSManaged public var dsb: DSB?

}

extension DSBPair : Identifiable {

}
