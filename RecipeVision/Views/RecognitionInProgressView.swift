//
//  RecognitionInProgressView.swift
//  RecipeVision
//
//  Created by Giorgio Latour on 9/21/23.
//

import SwiftUI

struct RecognitionInProgressView: View {
//    @EnvironmentObject var recognitionModel: IngredientRecognitionHandler
    
    @State private var animate: Bool = false
    
    var body: some View {
        VStack {
//            Text("\(recognitionModel.progressMessage)")
            Text("Recognition in Progress")
                .opacity(animate ? 1.0 : 0.2)
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
        .onAppear {
            withAnimation(.easeInOut(duration: 1).repeatForever()) {
                animate.toggle()
            }
        }
    }
}

#Preview {
    RecognitionInProgressView()
}
