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
    @Published var savedCards: [IngredientCard] = []
    
    lazy var persistentContainer = NSPersistentContainer(name: "RecipeVision")
    
    init() {
//        #if DEBUG
//        do {
//            // Use the container to initialize the development schema.
//            try persistentContainer.initializeCloudKitSchema(options: [])
//        } catch {
//            // Handle any errors.
//            print("An error occurred initializing the development schema: \(error.localizedDescription)")
//        }
//        #endif
        
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                print("There was an error loading the persistent stores: \(error.localizedDescription)")
                return
            } else {
                self.persistentContainer.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
                print("Successfully loaded CoreData.")
            }
        }
        
        fetchIngredientCards()
    }
    
    func fetchIngredientCards() {
        let request = NSFetchRequest<IngredientCard>(entityName: "IngredientCard")
        
        do {
            savedCards = try persistentContainer.viewContext.fetch(request)
        } catch {
            print("Error fetching: \(error)")
        }
    }
    
    func addCard(title: String = "No Title", ingredients: [String] = [String]()) {
        let newCard = IngredientCard(context: persistentContainer.viewContext)
        newCard.title = title
        newCard.id = UUID()
        newCard.timestamp = Date.now
        
        let ingredientsArr = ingredients.map { ingredient in
            let newIngredient = Ingredient(context: persistentContainer.viewContext)
            newIngredient.complete = false
            newIngredient.id = UUID()
            newIngredient.ingredient = ingredient
            newIngredient.ingredientCard = newCard
            
            return newIngredient
        }

        newCard.ingredients = NSSet(array: ingredientsArr)
        
        saveData()
    }
    
    func saveData() {
        do {
            try persistentContainer.viewContext.save()
            fetchIngredientCards()
        } catch {
            print("Error saving view context: \(error)")
        }
    }
}


