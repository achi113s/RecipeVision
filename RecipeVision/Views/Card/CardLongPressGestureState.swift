//
//  CardLongPressGestureState.swift
//  RecipeVision
//
//  Created by Giorgio Latour on 9/19/23.
//

import Foundation

enum CardLongPressGestureState {
    case inactive
    case pressing
    case finishedLongPress
    
    var isActive: Bool {
        switch self {
        case .inactive:
            return false
        case .pressing, .finishedLongPress:
            return true
        }
    }
    
    var isLongPressing: Bool {
        switch self {
        case .inactive, .finishedLongPress:
            return false
        case .pressing:
            return true
        }
    }
}


