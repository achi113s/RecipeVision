//
//  Ingredient+CoreDataProperties.swift
//  RecipeVision
//
//  Created by Giorgio Latour on 10/19/23.
//
//

import Foundation
import CoreData


extension Ingredient {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Ingredient> {
        return NSFetchRequest<Ingredient>(entityName: "Ingredient")
    }

    @NSManaged public var complete: Bool
    @NSManaged public var id: UUID
    @NSManaged public var ingredient: String
    @NSManaged public var ingredientCard: IngredientCard

}

extension Ingredient : Identifiable {

}
