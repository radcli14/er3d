//
//  Entity+Extensions.swift
//  EulerRotations3D
//
//  Created by Eliott Radcliffe on 1/29/25.
//

import Foundation
import RealityKit

extension Entity {
    func visitChildren(_ action: (Entity) -> Void) {
        children.forEach { child in
            action(child)
            child.visitChildren(action)
        }
    }
    
    /// Face in or out the visibility (opacity) of this entity
    /// - Parameters:
    /// - visible: will the outcome of the fade be the entity is visible (true) or invisible (false)
    /// - duration: the amount of time to fade between visibility settings
    /// - dt: the amount of time between visibility updates (i.e. frame rate)
    func fade(to visible: Bool, duration: Double = 0.5, dt: Double = 1.0 / 60.0) {
        // When we fade to invisible, we want the entity to be disabled at the end of the fade, however, in visible mode it should be visible enabled at all times
        if visible {
            isEnabled = true
        }
        
        // Add an opacity component, if one doesn't already exist. The initial state should be the opposite of the final
        let opacityComponent = OpacityComponent(opacity: visible ? 0 : 1)
        components.set(opacityComponent)

        // Run a timer that uniformly increments the opacity at every step of length dt
        var time = 0.0
        Timer.scheduledTimer(withTimeInterval: dt, repeats: true) { timer in
            self.components[OpacityComponent.self]?.opacity += Float(visible ? dt : -dt) / Float(duration)
            time += dt
            
            // At completion, make sure the opacity is exactly 0 or 1, and ensure it is in the proper enabled state, then exit the timer
            if time >= duration {
                self.components[OpacityComponent.self]?.opacity = visible ? 1 : 0
                self.isEnabled = visible
                timer.invalidate()
            }
        }
    }
}
