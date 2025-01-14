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
    var arView: ARView
    
    init() {
        // Load the globe model
        globe = try! Entity.load(named: "globe")
        globe.name = "GlobeEntity"
        let root = globe.findEntity(named: "Root")
        root?.transform = Transform(pitch: -.pi / 2)
        let sphere = globe.findEntity(named: "Sphere") as! ModelEntity
        
        // Generate collision shapes for the wrapper
        sphere.generateCollisionShapes(recursive: true)

        // Set up the ARView
        arView = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: true)
        
        // Create an AnchorEntity for the content
        let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
        arView.scene.anchors.append(anchor)
        
        // Add the globe wrapper to the anchor
        anchor.addChild(globe)
        
        // Install gestures on the globe wrapper
        arView.installGestures(.all, for: sphere)
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
