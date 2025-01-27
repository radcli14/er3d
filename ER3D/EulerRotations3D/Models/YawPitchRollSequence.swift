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
@Observable class YawPitchRollSequence: RotationSequence, HasLatLong {
    /// Rotation angle about the Yaw-Z axis in radians
    var first: EulerAngle = .yaw
    
    /// Rotation angle about the Pitch-Y axis in radians
    var second: EulerAngle = .pitch
    
    /// Rotation angle about the Roll-X axis in radians
    var third: EulerAngle = .roll
    
    /// Rotation angle north from the equator
    var lat: EulerAngle = .latitude
    
    /// Rotation angle about the north pole relative to GMT
    var long: EulerAngle = .longitude
    
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
        hideSkySphere()
    }
    
    private func hideSkySphere() {
        globe?.findEntity(named: "SkySphere")?.removeFromParent()
    }
    
    private func attachFrames() {
        first.frame = globe?.findEntity(named: "YawFrame")
        second.frame = globe?.findEntity(named: "PitchFrame")
        third.frame = globe?.findEntity(named: "RollFrame")
        lat.frame = globe?.findEntity(named: "Lat")
        long.frame = globe?.findEntity(named: "Long")
    }
    
    /// The globe should initially be invisible (zero scale) before entering the scene
    func setScaleToZero() {
        globe?.findEntity(named: "Sphere")?.transform.scale = SIMD3(0.0, 0.0, 0.0)
    }
    
    private func setInitialLatLong() {
        if let latRotation = lat.frame?.transform.rotation {
            if latRotation.angle.magnitude > 0 {
                lat.radians = -latRotation.angle * latRotation.axis.y
            }
        }
        if let longRotation = long.frame?.transform.rotation {
            if longRotation.angle.magnitude > 0 {
                long.radians = longRotation.angle * longRotation.axis.z
            }
        }
    }
    
    /// Set the angular position of the sun based on the date and time of day
    private func setSunLocation() {
        let azimuth = Date.now.solarTimeOffsetAngleRadians
        let azRotation = simd_quatf(angle: azimuth, axis: SIMD3(0, 0, -1)) // negative ECEF-Z, travels westward for increasing angle
        let elevation = Date.now.solarElevationAngleRadians
        let elRotation = simd_quatf(angle: elevation, axis: SIMD3(0, 1, 0))
        print("YawPitchRollSequence.setSunLocation(): azimuth = \(azimuth * 180 / .pi) deg, elevation = \(elevation * 180 / .pi) deg")
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
        transform.rotation = simd_quatf(angle: -long.radians + 0.5 * .pi, axis: SIMD3(0, 1, 0))
        transform.scale = SIMD3<Float>(1.0, 1.0, 1.0)
        sphere.move(to: transform, relativeTo: sphere.parent, duration: 2.0)
        print("  - Moving to \(transform)")
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
}
