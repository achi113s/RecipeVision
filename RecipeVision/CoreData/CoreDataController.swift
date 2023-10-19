//
//  CoreDataController.swift
//  RecipeVision
//
//  Created by Giorgio Latour on 10/18/23.
//

import CoreData
import Foundation

class CoreDataController: ObservableObject {
    // Set up the model, context, and store all at once.
    lazy var persistentContainer = NSPersistentContainer(name: "RecipeVision")
    
    init() {
//        #if DEBUG
//        do {
//            // Use the container to initialize the development schema.
//            try persistentCKContainer.initializeCloudKitSchema(options: [])
//        } catch {
//            // Handle any errors.
//            print("An error occurred initializing the development schema: \(error.localizedDescription)")
//        }
//        #endif
        
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                print("There was an error loading the persistent stores: \(error.localizedDescription)")
                return
            }
            
            self.persistentContainer.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        }
    }
}


