//
//  CardView.swift
//  RecipeVision
//
//  Created by Giorgio Latour on 9/17/23.
//

import SwiftUI

struct CardView: View {
    @Binding var ingredientCard: IngredientCard
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 15) {
                Text(ingredientCard.name)
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundColor(Color("AccentColor"))
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(ingredientCard.ingredients, id: \.id) { ingredient in
                        HStack(alignment: .center) {
                            SwipeToCompleteTextView(
                                complete: $ingredientCard.ingredients[ingredientCard.ingredients.firstIndex(of: ingredient)!].complete,
                                text: ingredient.name)
                            .textColor(Color("AccentColor"))
                            .strikethroughColor(Color("AccentColor"))
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                        }
                    }
                }
            }
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 30)
        .mask {
            RoundedRectangle(cornerRadius: 25)
        }
        .background {
            RoundedRectangle(cornerRadius: 25)
                .fill(Color("CardBackground"))
                .shadow(radius: 4)
                .frame(maxWidth: .infinity)
        }
    }
    
    init(ingredientCard: Binding<IngredientCard>) {
        self._ingredientCard = ingredientCard
    }
}

#Preview {
    CardView(ingredientCard: .constant(
        IngredientCard(
            name: "Green Tea Ice Cream",
            ingredients: [
                Ingredient("1 cup (250ml) whole milk"),
                Ingredient("3/4 cup (150g) sugar"),
                Ingredient("pinch of kosher or sea salt"),
                Ingredient("2 cups (500ml) heavy cream"),
                Ingredient("4 teaspoons matcha (green tea powder)"),
                Ingredient("6 large egg yolks")
            ]
        )
    ))
}
