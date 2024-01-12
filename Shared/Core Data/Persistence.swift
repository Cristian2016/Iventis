//
//  Persistence.swift
//  Shared
//
//  Created by Cristian Lapusan on 15.04.2022.
//

import CoreData

struct PersistenceController {
    private static let colors = [
        "red", "ultramarine", "orange", "sky", "magenta", "gray", "lemon", "charcoal"
    ]
    
    static var shared = PersistenceController()

    // MARK: -
    let container: NSPersistentContainer
    
    lazy var viewContext = container.viewContext
    
    lazy var bContext:NSManagedObjectContext = {
       let bContext = container.newBackgroundContext()
        
        //should conflicts arise, the in-memory version trumps store version
        bContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return bContext
    }()
    
    mutating func grabObj(_ objectID:NSManagedObjectID) -> NSManagedObject {
        bContext.object(with: objectID)
    }
    
    ///closure inserts code right after successful save, within do statement
    func save(_ context:NSManagedObjectContext? = PersistenceController.shared.viewContext, completion: (() -> Void)? = nil) {
        guard let context = context else { return }
        
        if context.hasChanges {
            do {
                try context.save()
                completion?()
            } catch let error {
                print("problemo with saving, dumb dumb!!! ", error.localizedDescription)
            }
        }
    }
            
    // MARK: - Init
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Model")
        
        //one shared database for App Widgets and Siri
        let sharedDatabase = URL.sharedContainer.appendingPathComponent("sharedDatabase.sqlite")
        
        //moved database to shared location
        //overrides the type (or types) of persistent store(s) used by the container
        container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: sharedDatabase)]
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { description, error in
            if let _ = error as NSError? { fatalError() }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

public extension URL {
    static var sharedContainer:URL = {
        guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: .appGroupName)
        else { fatalError() }
        return url
    }()
    
    ///shared file for storing objectID of the most recently used bubble
    static let objectIDFileURL = URL.sharedContainer.appendingPathComponent("objectID")
}

extension UserDefaults {
    static let shared = UserDefaults(suiteName: .appGroupName)!
}

public extension String {
    //group.com.Eventify.container
    static let appGroupName = "group.com.Iventis"
}

///used for widgets only
struct BubbleData:Codable {
    let value:Float
    let isTimer:Bool
    let isRunning:Bool
}
