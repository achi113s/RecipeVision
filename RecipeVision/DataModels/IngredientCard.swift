//
//  IngredientCard.swift
//  RecipeVision
//
//  Created by Giorgio Latour on 9/18/23.
//

import SwiftUI

//class IngredientCards: ObservableObject {
//    @Published var ingredientCards: [IngredientCard]
//    
//    init() {
//        self.ingredientCards = [
//            IngredientCard(
//                name: "Green Tea Ice Cream",
//                ingredients: [
//                    Ingredient("1 cup (250ml) whole milk"),
//                    Ingredient("3/4 cup (150g) sugar"),
//                    Ingredient("pinch of kosher or sea salt"),
//                    Ingredient("2 cups (500ml) heavy cream"),
//                    Ingredient("4 teaspoons matcha (green tea powder)"),
//                    Ingredient("6 large egg yolks")
//                ]
//            )
//        ]
//    }
//    
//    public func addNewCard(_ newCard: IngredientCard) {
//        ingredientCards.append(newCard)
//    }
//}
//
//struct IngredientCard: Identifiable, Hashable {
//    let id: UUID = UUID()
//    let name: String
//    var ingredients: [Ingredient]
//    
//    init(name: String = "Card Name", ingredients: [Ingredient]) {
//        self.name = name
//        self.ingredients = ingredients
//    }
//    
//    init(decodedIngredients: DecodedIngredients) {
//        self.name = "New Card"
//        self.ingredients = decodedIngredients.ingredients.map({ ingredientName in
//            return Ingredient(ingredientName)
//        })
//    }
//}
//
//struct Ingredient: Identifiable, Hashable {
//    let id: UUID = UUID()
//    var name: String
//    var complete: Bool
//    
//    init(_ name: String, complete: Bool = false) {
//        self.name = name
//        self.complete = complete
//    }
//    
//    mutating func toggleComplete() {
//        self.complete.toggle()
//    }
//}
