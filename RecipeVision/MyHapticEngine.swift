//
//  MyHapticEngine.swift
//  RecipeVision
//
//  Created by Giorgio Latour on 9/18/23.
//

import CoreHaptics
import SwiftUI

class MyHapticEngine: ObservableObject {
    @Published var hapticEngine: CHHapticEngine? = nil
    
    private func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            print("The device does not support haptics.")
            return
        }
        
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
            print("haptic engine started")
        } catch {
            print("There was an error creating the haptic engine: \(error.localizedDescription)")
        }
    }
    
    public func playSuccessHaptic() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            print("The device does not support haptics.")
            return
        }
        
        if hapticEngine == nil {
            prepareHaptics()
        }
        
        var events = [CHHapticEvent]()
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        events.append(event)
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try hapticEngine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
            print("played")
        } catch {
            print("Failed to play pattern: \(error.localizedDescription)")
        }
    }
}
