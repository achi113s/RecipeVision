//
//  RecipeVisionApp.swift
//  RecipeVision
//
//  Created by Giorgio Latour on 9/3/23.
//

import SwiftUI

@main
struct RecipeVisionApp: App {
    @StateObject private var coreDataController = CoreDataController()
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .preferredColorScheme(.light)
                .environment(\.managedObjectContext, coreDataController.persistentContainer.viewContext)
                .environmentObject(coreDataController)
        }
    }
}
