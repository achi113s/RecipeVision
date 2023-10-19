//
//  SettingsView.swift
//  RecipeVision
//
//  Created by Giorgio Latour on 10/19/23.
//

import SwiftUI

struct SettingsView: View {
    //    @EnvironmentObject var mainViewModel: MainViewModel
    @Binding var path: NavigationPath
    
    var body: some View {
        VStack {
            Text("Settings View")
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Settings")
    }
}

#Preview {
    SettingsView(path: .constant(NavigationPath()))
}
