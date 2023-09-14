//
//  ContentView.swift
//  RecipeVision
//
//  Created by Giorgio Latour on 9/3/23.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var visionModel: VisionViewModel = VisionViewModel()
    
    @State private var presentCameraView: Bool = false
    
    var body: some View {
        NavigationStack {
            PlaceholderView()
                .toolbar {
                    Group {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Text("RecipeVision")
                                .multilineTextAlignment(.center)
                                .font(.system(size: 32, weight: .semibold, design: .rounded))
                                .foregroundColor(Color("AccentColor"))
                        }
                        
                        ToolbarItem {
                            Button {
                                presentCameraView.toggle()
                            } label: {
                                Image(systemName: "camera.on.rectangle")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
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
        .environmentObject(visionModel)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
