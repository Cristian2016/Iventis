//
//  TimerDuration+CoreDataProperties.swift
//  Timers
//
//  Created by Cristian Lapusan on 20.05.2023.
//
//

import Foundation
import CoreData


extension TimerDuration {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TimerDuration> {
        return NSFetchRequest<TimerDuration>(entityName: "TimerDuration")
    }

    @NSManaged public var value: Float
    @NSManaged public var date: Date?
    @NSManaged public var history: TimerHistory?
}

extension TimerDuration : Identifiable {

}
