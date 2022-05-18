//
//  OldBubbleNote+CoreDataClass.swift
//  Timers
//
//  Created by Cristian Lapusan on 19.05.2022.
//
//

import Foundation
import CoreData

@objc(OldBubbleNote)
public class OldBubbleNote: NSManagedObject {
    //up to 100 old notes are being stored
    static let limit = 100
}
