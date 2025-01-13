//
//  ER3DRealityViewModel.swift
//  ER3D
//
//  Created by Eliott Radcliffe on 1/13/25.
//

import Foundation
import RealityKit

@Observable class ER3DRealityViewModel {
    let globe: Entity
    
    init() {
        globe = try! Entity.load(named: "globe")
        
        // Rotate the globe's Root entity so the north pole (Z-axis) faces upward
        let root = globe.findEntity(named: "Root")!
        root.transform = Transform(pitch: -.pi / 2)
    }
    
    var controlVisibility: ControlVisibility = .bottomButtons
    
    // MARK: - Euler Angles
    
    var yaw: Float = 0.0 {
        didSet {
            globe.findEntity(named: "YawFrame")?.transform = Transform(roll: yaw)
        }
    }
    
    var pitch: Float = 0.0 {
        didSet {
            globe.findEntity(named: "PitchFrame")?.transform = Transform(yaw: pitch)
        }
    }
    
    var roll: Float = 0.0 {
        didSet {
            globe.findEntity(named: "RollFrame")?.transform = Transform(pitch: roll)
        }
    }
    
    func resetYawPitchRollAngles() {
        yaw = 0.0
        pitch = 0.0
        roll = 0.0
    }
    
    // MARK: - Latitude and Longitude
    
    var lat: Float = 0.0
    var long: Float = 0.0
    
    func resetLatLong() {
        lat = 0.0
        long = 0.0
    }
}
