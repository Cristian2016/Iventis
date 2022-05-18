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
    
    ///all old notes sorted by Date
    static func all() -> [OldBubbleNote] {
        let request = OldBubbleNote.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "created", ascending: false)
        ]
      return (try? PersistenceController.shared.viewContext.fetch(request)) ?? []
    }
}
