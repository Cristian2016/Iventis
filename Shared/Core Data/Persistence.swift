//
//  Persistence.swift
//  Shared
//
//  Created by Cristian Lapusan on 15.04.2022.
//

import CoreData

struct PersistenceController {
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Model")
        
        //one shared database for App Widgets and Siri
        let sharedDataBaseURL = FileManager.sharedContainerURL.appendingPathComponent("sharedDatabase.sqlite")
        let description = NSPersistentStoreDescription(url: sharedDataBaseURL)
        container.persistentStoreDescriptions = [description]
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    static var shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newItem = Bubble(context: viewContext)
            newItem.created = Date()
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
    
    lazy var backgroundContext = container.newBackgroundContext()
    
    func save(_ context:NSManagedObjectContext = PersistenceController.shared.viewContext) {
        if context.hasChanges { try? context.save() }
    }
}
