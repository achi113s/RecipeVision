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
    private var hapticEngineWasStopped: Bool = false
    
    lazy var simpleSuccessHapticEvent: [CHHapticEvent] = {
        var events = [CHHapticEvent]()
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        events.append(event)
        
        return events
    }()
    
    lazy var longPressSuccessHapticEvent: [CHHapticEvent] = {
        var events = [CHHapticEvent]()
        
        for i in stride(from: 0, to: 0.2, by: 0.1) {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: i)
            events.append(event)
        }
        
        return events
    }()
    
    private func prepareHapticsSync() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            print("The device does not support haptics.")
            return
        }
        
        
        
        do {
            hapticEngine = try CHHapticEngine()
            
            hapticEngine?.stoppedHandler = { _ in
                self.hapticEngineWasStopped = true
            }
            
            try hapticEngine?.start()
            print("haptic engine started")
        } catch {
            print("There was an error creating the haptic engine: \(error.localizedDescription)")
        }
    }
    
    public func playHaptic(_ hapticType: MyHapticType) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            print("The device does not support haptics.")
            return
        }
        
        if hapticEngine == nil {
            // when calling this for the first time, there is some lag due to using the synchronous start() method
            prepareHapticsSync()
        } else if hapticEngineWasStopped {
            prepareHapticsSync()
            hapticEngineWasStopped = false
        }
        
        do {
            var events: [CHHapticEvent] = []
            
            switch hapticType {
            case .simpleSuccess:
                events = simpleSuccessHapticEvent
            case .longPressSuccess:
                events = longPressSuccessHapticEvent
            }
            
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try hapticEngine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
            print("played")
        } catch {
            print("Failed to play pattern: \(error.localizedDescription)")
        }
    }
}
