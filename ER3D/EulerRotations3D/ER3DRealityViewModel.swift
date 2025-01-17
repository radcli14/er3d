//
//  ER3DRealityViewModel.swift
//  ER3D
//
//  Created by Eliott Radcliffe on 1/13/25.
//

import Foundation
import RealityKit
import SwiftUI
import UIKit

@Observable class ER3DRealityViewModel {
    var arView: ARView
    var anchor: AnchorEntity
    var globe: Entity?
    var controlVisibility: ControlVisibility = .bottomButtons
    
    init() {
        // Set up the ARView
        arView = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: true)
        //arView.environment.sceneUnderstanding.options.insert(.collision)
        //arView.environment.sceneUnderstanding.options.insert(.receivesLighting)
        //arView.environment.sceneUnderstanding.options.insert(.occlusion)
        //arView.debugOptions = [.showFeaturePoints, .showWorldOrigin, .showAnchorOrigins, .showSceneUnderstanding, .showPhysics]
        
        // Create an AnchorEntity for the content
        anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
        anchor.transform.rotation = simd_quatf(angle: .pi, axis: SIMD3<Float>(0, 1, 0))
        arView.scene.anchors.append(anchor)
        
        // Load the globe model asynchronously
        Task {
            await loadGlobe()
        }
    }
    
    /// Load the globe model asynchronously, set up the sphere and ship with collisions, and add it to the arView
    private func loadGlobe() async {
        if #available(iOS 18.0, *) {
            globe = try? await Entity(named: "globe")
        } else {
            fatalError("iOS version is too low to load the globe model, must be >=18.0")
        }
        guard let globe else { return }
        setInitialLatLong()
        addGlobeGestures()
        //addShipGestures()
        await anchor.addChild(globe)
    }
    
    private func setInitialLatLong() {
        if let latRotation = globe?.findEntity(named: "Lat")?.transform.rotation {
            if latRotation.angle.magnitude > 0 {
                lat = -Constants.rad2deg * latRotation.angle * latRotation.axis.y
            }
        }
        if let longRotation = globe?.findEntity(named: "Long")?.transform.rotation {
            if longRotation.angle.magnitude > 0 {
                long = Constants.rad2deg * longRotation.angle * longRotation.axis.z
            }
        }
    }
    
    // MARK: - State Changes
    
    /// When the user toggles to lat/long control, remove the ARView gestures, or add them back in when toggling away
    func handleControlVisibilityChange() {
        if controlVisibility == .latLongControls {
            removeGlobeGestures()
        } else {
            addGlobeGestures()
        }
    }
    
    // MARK: - Gestures
    
    private func remove(_ gestures: [any EntityGestureRecognizer]?) {
        gestures?.forEach { recognizer in
            if let idx = arView.gestureRecognizers?.firstIndex(of: recognizer) {
                arView.gestureRecognizers?.remove(at: idx)
            }
        }
    }
    
    private var globeGestures: [any EntityGestureRecognizer]?
    
    /// Set up the sphere collisions and gestures which allow you to move, rotate, and scale the globe
    func addGlobeGestures() {
        if let sphere = globe?.findEntity(named: "Sphere") as? ModelEntity {
            sphere.generateCollisionShapes(recursive: false)
            globeGestures = arView.installGestures(.all, for: sphere)
        }
    }
    
    /// Remove the globe gestures to enable separate gestures to modify latitude and longitude
    func removeGlobeGestures() {
        remove(globeGestures)
        
        // Retain rotation gesture
        if let sphere = globe?.findEntity(named: "Sphere") as? ModelEntity {
            globeGestures = arView.installGestures(.rotation, for: sphere)
        }
    }
    
    private var shipGestures: [any EntityGestureRecognizer]?
    
    /// Set up the ship collisions and gestures which allow you to pivot the ship around the earth center to modify latitude and longitude
    func addShipGestures() {
        // TODO: this function appears to have no effect, or intermittent effect
        if let ship = globe?.findEntity(named: "Space_Shuttle_Discovery"),
           let node = ship.findEntity(named: "node_0") as? ModelEntity {
            node.generateCollisionShapes(recursive: true)
            shipGestures = arView.installGestures(.translation, for: node)
            shipGestures?.forEach { gesture in
                gesture.addTarget(self, action: #selector(handleShipGesture(_:)))
            }
        }
    }
    
    func removeShipGestures() {
        remove(shipGestures)
        shipGestures = nil
    }
    
    @objc private func handleShipGesture(_ gesture: UIGestureRecognizer) {
        print("Gesture detected: \(gesture.state)")
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
    
    /// Sets the rate at which the position of the ship model will change based on a translation gesture when the lat/long controls are active
    let latLongScale: Float = -0.1
    
    /// Latitude angle in degrees
    var lat: Float = 0.0 {
        didSet {
            globe?.findEntity(named: "Lat")?.transform = Transform(yaw: -lat * Constants.deg2rad)
        }
    }
    
    /// Longitude angle in degrees
    var long: Float = 0.0 {
        didSet {
            globe?.findEntity(named: "Long")?.transform = Transform(roll: long * Constants.deg2rad)
        }
    }
    
    /// Resets the latitude and longitude angles to zero (off the cape of Africa)
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
