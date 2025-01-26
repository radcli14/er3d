//
//  YawPitchRollSequence.swift
//  EulerRotations3D
//
//  Created by Eliott Radcliffe on 1/26/25.
//

import Foundation
import RealityKit
import Globe

/// Provides the globe model to teach the Yaw → Pitch → Roll Euler angle sequence
class YawPitchRollSequence: RotationSequence {
    /// Rotation angle about the Yaw-Z axis in radians
    var first: EulerAngle = .yaw
    
    /// Rotation angle about the Pitch-Y axis in radians
    var second: EulerAngle = .pitch
    
    /// Rotation angle about the Roll-X axis in radians
    var third: EulerAngle = .roll
    
    /// The globe as the root entity
    var rootEntity: Entity? { globe }
    private var globe: Entity?

    // MARK: - Initialization
    
    init() {
        Task {
            await loadGlobe()
        }
    }
    
    /// Load the globe model asynchronously, set up the sphere and ship with collisions, and add it to the arView
    private func loadGlobe() async {
        globe = try? await Entity(named: "globe", in: Globe.globeBundle)
        attachFrames()
        setSunLocation()
        setInitialLatLong()
        setScaleToZero()
    }
    
    private func attachFrames() {
        first.frame = globe?.findEntity(named: "YawFrame")
        second.frame = globe?.findEntity(named: "PitchFrame")
        third.frame = globe?.findEntity(named: "RollFrame")
    }
    
    /// The globe should initially be invisible (zero scale) before entering the scene
    func setScaleToZero() {
        globe?.findEntity(named: "Sphere")?.transform.scale = SIMD3(0.0, 0.0, 0.0)
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
    
    /// Set the angular position of the sun based on the date and time of day
    private func setSunLocation() {
        let azimuth = Date.now.solarTimeOffsetAngleRadians
        let azRotation = simd_quatf(angle: azimuth, axis: SIMD3(0, 0, -1)) // negative ECEF-Z, travels westward for increasing angle
        let elevation = Date.now.solarElevationAngleRadians
        let elRotation = simd_quatf(angle: elevation, axis: SIMD3(0, 1, 0))
        print("YawPitchRollSequence.setSunLocation(): azimuth = \(azimuth * Constants.rad2deg) deg, elevation = \(elevation * Constants.rad2deg) deg")
        globe?.findEntity(named: "SunAzimuth")?.transform.rotation = azRotation
        globe?.findEntity(named: "SunElevation")?.transform.rotation = elRotation
    }
    
    /// Animate the globe appearing and rotating to its initial longitude
    func animateEnteringScene() {
        print("YawPitchRollSequence.animateEnteringScene()")
        guard let sphere = globe?.findEntity(named: "Sphere") else { return }
        print("  - Got sphere")
        // Get the default transform
        var transform = sphere.transform
        
        // Animate the globe appearing and rotating to its initial longitude
        globe?.transform.translation = .zero
        transform.translation = SIMD3(0, 0.7, 0)
        transform.rotation = simd_quatf(angle: (-long+90) * Constants.deg2rad, axis: SIMD3(0, 1, 0))
        transform.scale = SIMD3<Float>(1.0, 1.0, 1.0)
        sphere.move(to: transform, relativeTo: sphere.parent, duration: 2.0)
        print("  - Moving to \(transform)")
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
    
    // MARK: - Gestures

    /// The translation gesture on the globe touch cylinder, separated from the other gestures becasue we will add and remove it depending on if the user is viewing latitude and longitude
    var globeTranslationGesture: EntityGestureRecognizer?
    
    /// The two finger gestures for rotation and scale of the globe sphere
    var globeRotationAndScaleGestures: [any EntityGestureRecognizer]?

    /// Set up the sphere collisions and gestures which allow you to move, rotate, and scale the globe
    func addGestures(to arView: ARView) {
        print("YawPitchRollSequence.addGestures()")
        if let sphere = globe?.findEntity(named: "Sphere") as? ModelEntity {
            if sphere.components[CollisionComponent.self] == nil {
                print("  - Generating collision shapes for the sphere")
                sphere.generateCollisionShapes(recursive: false)
            }
            if globeTranslationGesture == nil {
                print("  - Installing translation gesture")
                globeTranslationGesture = arView.installGestures(.translation, for: sphere).first
            }
            if globeRotationAndScaleGestures == nil {
                print("  - Installing rotation and scale gestures")
                globeRotationAndScaleGestures = arView.installGestures([.rotation, .scale], for: sphere)
            }
        }
    }
    /// Remove the globe translation gestures to enable separate gestures to modify latitude and longitude
    func removeTranslationGesture(from arView: ARView) {
        print("YawPitchRollSequence.removeTranslationGesture()")
        remove(globeTranslationGesture, from: arView)
        globeTranslationGesture = nil
    }

    // MARK: - Constants
    
    private struct Constants {
        static let rad2deg: Float = 180 / .pi
        static let deg2rad: Float = .pi / 180
    }
}
