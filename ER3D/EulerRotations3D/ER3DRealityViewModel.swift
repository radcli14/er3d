//
//  ER3DRealityViewModel.swift
//  ER3D
//
//  Created by Eliott Radcliffe on 1/13/25.
//

import Foundation
import RealityKit

@Observable class ER3DRealityViewModel {
    var arView: ARView
    var anchor: AnchorEntity
    var globe: Entity?
    var controlVisibility: ControlVisibility = .bottomButtons
    
    init() {
        // Set up the ARView
        arView = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: true)
        
        // Create an AnchorEntity for the content
        anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
        arView.scene.anchors.append(anchor)

        // Load the globe model asynchronously
        Task {
            await loadGlobe()
        }
    }
    
    /// Load the globe model asynchronously, set up the sphere with collisions, and add it to the arView
    private func loadGlobe() async {
        // Load the globe model asynchronously
        globe = try? await Entity(named: "globe")
        guard let globe else { return }
        
        // Set up the sphere collisions and gestures which allow you to move, rotate, and scale
        let sphere = await globe.findEntity(named: "Sphere") as! ModelEntity
        await sphere.generateCollisionShapes(recursive: false)
        await arView.installGestures(.all, for: sphere)
        
        // Add the globe to the AR view
        await anchor.addChild(globe)
    }
    
    // MARK: - Euler Angles

    /// Rotation angle about the Yaw-Z axis in radians
    var yaw: Float = 0.0 {
        didSet {
            globe?.findEntity(named: "YawFrame")?.transform = Transform(roll: yaw)
        }
    }
    
    /// Rotation angle about the Pitch-Y axis in radians
    var pitch: Float = 0.0 {
        didSet {
            globe?.findEntity(named: "PitchFrame")?.transform = Transform(yaw: pitch)
        }
    }
    
    /// Rotation angle about the Roll-X axis in radians
    var roll: Float = 0.0 {
        didSet {
            globe?.findEntity(named: "RollFrame")?.transform = Transform(pitch: roll)
        }
    }
    
    /// Set each of the euler angles to zero
    func resetYawPitchRollAngles() {
        yaw = 0.0
        pitch = 0.0
        roll = 0.0
    }
    
    // MARK: - Latitude and Longitude
    
    var lat: Float = 0.0 {
        didSet {
            globe?.findEntity(named: "Lat")?.transform = Transform(yaw: lat)
        }
    }
    
    var long: Float = 0.0 {
        didSet {
            globe?.findEntity(named: "Long")?.transform = Transform(roll: long)
        }
    }
    
    func resetLatLong() {
        lat = 0.0
        long = 0.0
    }
    
    // MARK: - Constants
    
    private struct Constants {
        static let rad2deg: Float = 180 / .pi
        static let deg2rad: Float = .pi / 180
    }
}
