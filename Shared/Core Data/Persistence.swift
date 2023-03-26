//
//  Persistence.swift
//  Shared
//
//  Created by Cristian Lapusan on 15.04.2022.
//⚠️ I replaced mergePolicy with automaticallyMergesChangesFromParent! make sure it does not crash

import CoreData

struct PersistenceController {
    private static let colors = [
        "red", "ultramarine", "orange", "sky", "magenta", "silver", "lemon", "charcoal"
    ]
    
    static var shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for index in 0..<8 {
            let newBubble = Bubble(context: viewContext)
            newBubble.created = Date()
            newBubble.color = colors[index]
            newBubble.rank = Int64(index)
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    // MARK: -
    let container: NSPersistentContainer
    
    lazy var viewContext = container.viewContext
    
    lazy var bContext:NSManagedObjectContext = {
       let bContext = container.newBackgroundContext()
        
        //updates are propagated between bContext and my viewContext
        bContext.automaticallyMergesChangesFromParent = true //⚠️
        
        return bContext
    }()
    
    mutating func grabObj(_ objectID:NSManagedObjectID) -> NSManagedObject {
        bContext.object(with: objectID)
    }
    
    ///closure inserts code right after successful save, within do statement
    func save(_ context:NSManagedObjectContext? = PersistenceController.shared.viewContext, closure: (() -> Void)? = nil) {
        guard let context = context else { return }
        
        if context.hasChanges {
            do {
                try context.save()
                closure?()
            } catch let error {
                print("problemo with saving, dumb dumb!!! ", error.localizedDescription)
            }
        }
    }
    
    // MARK: - Init
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Model")
        
        //one shared database for App Widgets and Siri
        let sharedDatabase = URL.sharedContainerURL.appendingPathComponent("sharedDatabase.sqlite")
                
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
