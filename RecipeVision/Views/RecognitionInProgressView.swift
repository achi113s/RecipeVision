//
//  RecognitionInProgressView.swift
//  RecipeVision
//
//  Created by Giorgio Latour on 9/21/23.
//

import SwiftUI

struct RecognitionInProgressView: View {
    @State var progress: CGFloat
    
    var body: some View {
        VStack {
            Text("\(progress)")
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
}

#Preview {
    RecognitionInProgressView(progress: 0.0)
}
