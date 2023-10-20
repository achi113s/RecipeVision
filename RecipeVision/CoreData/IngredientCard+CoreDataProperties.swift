//
//  IngredientCard+CoreDataProperties.swift
//  RecipeVision
//
//  Created by Giorgio Latour on 10/19/23.
//
//

import Foundation
import CoreData


extension IngredientCard {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<IngredientCard> {
        return NSFetchRequest<IngredientCard>(entityName: "IngredientCard")
    }

    @NSManaged public var id: UUID
    @NSManaged public var timestamp: Date
    @NSManaged public var title: String?
    @NSManaged public var ingredients: NSSet
    
    var ingredientsArray: [Ingredient] {
        let sortDescriptor = NSSortDescriptor(key: "ingredient", ascending: true)
        return ingredients.sortedArray(using: [sortDescriptor]) as? [Ingredient] ?? [Ingredient]()
    }
}

// MARK: Generated accessors for ingredients
extension IngredientCard {

    @objc(insertObject:inIngredientsAtIndex:)
    @NSManaged public func insertIntoIngredients(_ value: Ingredient, at idx: Int)

    @objc(removeObjectFromIngredientsAtIndex:)
    @NSManaged public func removeFromIngredients(at idx: Int)

    @objc(insertIngredients:atIndexes:)
    @NSManaged public func insertIntoIngredients(_ values: [Ingredient], at indexes: NSIndexSet)

    @objc(removeIngredientsAtIndexes:)
    @NSManaged public func removeFromIngredients(at indexes: NSIndexSet)

    @objc(replaceObjectInIngredientsAtIndex:withObject:)
    @NSManaged public func replaceIngredients(at idx: Int, with value: Ingredient)

    @objc(replaceIngredientsAtIndexes:withIngredients:)
    @NSManaged public func replaceIngredients(at indexes: NSIndexSet, with values: [Ingredient])

    @objc(addIngredientsObject:)
    @NSManaged public func addToIngredients(_ value: Ingredient)

    @objc(removeIngredientsObject:)
    @NSManaged public func removeFromIngredients(_ value: Ingredient)

    @objc(addIngredients:)
    @NSManaged public func addToIngredients(_ values: NSOrderedSet)

    @objc(removeIngredients:)
    @NSManaged public func removeFromIngredients(_ values: NSOrderedSet)

}

extension IngredientCard : Identifiable {

}
