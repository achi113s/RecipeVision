//
//  NewIngredientsView.swift
//  RecipeVision
//
//  Created by Giorgio Latour on 9/30/23.
//

import SwiftUI

struct NewIngredientsView: View {
    @State private var ingredients: [String]
    @State private var editMode: EditMode = .active
    @State private var title: String = "Name Your Ingredients"
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color("BackgroundColor")
                    .edgesIgnoringSafeArea(.all)
                List {
                    Section {
                        TextField("Recipe Title", text: $title)
                            .disabled(editMode == .inactive)
                            .font(.system(.title3))
                            .fontDesign(.rounded)
                            .fontWeight(.semibold)
                            .padding()
                    }
                    
                    Section {
                        ForEach($ingredients, id: \.hashValue) { $ingredient in
                            TextField("Ingredient", text: $ingredient, axis: .vertical)
                                .disabled(editMode == .inactive)
                                .fontDesign(.rounded)
                                .fontWeight(.semibold)
                        }
                        .onDelete(perform: onDelete)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        EditButton()
                            .fontDesign(.rounded)
                            .fontWeight(.semibold)
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            print("hello")
                        } label: {
                            Text("Save")
                                .fontDesign(.rounded)
                                .fontWeight(.semibold)
                        }
                    }
                }
                .environment(\.editMode, $editMode)
                .scrollContentBackground(.hidden)
                .toolbarBackground(Color("ToolbarBackground"), for: .automatic)
            }
        }
    }
    
    private func onDelete(offsets: IndexSet) {
        ingredients.remove(atOffsets: offsets)
    }
    
    init(ingredients: [String], editMode: EditMode = .active) {
        self._ingredients = State(initialValue: ingredients)
        self.editMode = editMode
    }
}

#Preview {
    NewIngredientsView(ingredients: [
        "½ cup heavy cream",
        "10 ounces fresh unsalted fatback or lean salt pork, cut into small dice",
        "About 1 quart water",
        "1 cup diced carrot (⅛- to ¼-inch dice)",
        "⅔ cup diced celery (same dimensions)",
        "½ cup diced onion (same dimensions)",
        "1¼ pounds beef skirt steak or boneless chuck blade roast, coarsely ground",
        "½ cup dry Italian white wine, preferably Trebbiano or Albana",
        "2 tablespoons double or triple-concentrated imported Italian tomato paste, diluted in 10 tablespoons Poultry/ Meat Stock (page 66) or Quick Stock (page 68)",
        "1 cup whole milk",
        "Salt and freshly ground black pepper to taste"
    ])
}
