//
//  TimerHistory+CoreDataProperties.swift
//  Timers
//
//  Created by Cristian Lapusan on 20.05.2023.
//
//

import Foundation
import CoreData


extension TimerHistory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TimerHistory> {
        return NSFetchRequest<TimerHistory>(entityName: "History")
    }

    @NSManaged public var timerDurations: NSOrderedSet?

}

// MARK: Generated accessors for timerDurations
extension TimerHistory {

    @objc(insertObject:inTimerDurationsAtIndex:)
    @NSManaged public func insertIntoTimerDurations(_ value: TimerDuration, at idx: Int)

    @objc(removeObjectFromTimerDurationsAtIndex:)
    @NSManaged public func removeFromTimerDurations(at idx: Int)

    @objc(insertTimerDurations:atIndexes:)
    @NSManaged public func insertIntoTimerDurations(_ values: [TimerDuration], at indexes: NSIndexSet)

    @objc(removeTimerDurationsAtIndexes:)
    @NSManaged public func removeFromTimerDurations(at indexes: NSIndexSet)

    @objc(replaceObjectInTimerDurationsAtIndex:withObject:)
    @NSManaged public func replaceTimerDurations(at idx: Int, with value: TimerDuration)

    @objc(replaceTimerDurationsAtIndexes:withTimerDurations:)
    @NSManaged public func replaceTimerDurations(at indexes: NSIndexSet, with values: [TimerDuration])

    @objc(addTimerDurationsObject:)
    @NSManaged public func addToTimerDurations(_ value: TimerDuration)

    @objc(removeTimerDurationsObject:)
    @NSManaged public func removeFromTimerDurations(_ value: TimerDuration)

    @objc(addTimerDurations:)
    @NSManaged public func addToTimerDurations(_ values: NSOrderedSet)

    @objc(removeTimerDurations:)
    @NSManaged public func removeFromTimerDurations(_ values: NSOrderedSet)

}

extension TimerHistory : Identifiable {

}
