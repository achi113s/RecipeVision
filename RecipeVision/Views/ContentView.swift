//
//  ContentView.swift
//  RecipeVision
//
//  Created by Giorgio Latour on 9/3/23.
//

import SwiftUI

struct ContentView: View {
    @State private var presentCameraView: Bool = false
    
    var body: some View {
        NavigationStack {
            PlaceholderView()
                .toolbar {
                    Group {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Text("Recipe Vision")
                                .multilineTextAlignment(.center)
                                .font(.system(size: 30, weight: .semibold, design: .rounded))
                                .foregroundColor(Color("AccentColor"))
                        }
                        
                        ToolbarItem {
                            Button {
                                presentCameraView.toggle()
                            } label: {
                                Image(systemName: "camera.on.rectangle")
                                    .foregroundColor(Color("AccentColor"))
                            }
                        }
                        
                        ToolbarItem {
                            Button {
                                print("camera")
                            } label: {
                                Image(systemName: "gear")
                                    .foregroundColor(Color("AccentColor"))
                            }
                        }
                    }
                }
                .toolbarBackground(Color("ToolbarBackground"), for: .automatic)
                .sheet(isPresented: $presentCameraView) {
                    CameraView()
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
