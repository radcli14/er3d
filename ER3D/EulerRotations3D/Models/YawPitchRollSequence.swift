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
    
    /// The sphere as the root entity
    var rootEntity: Entity?

    /// The globe which can be referenced when searching for child entities
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
        rootEntity = await globe?.findEntity(named: "Sphere") // I need to set the sphere as root because the root was acting as an anchor and ignoring its parent tranform. This is a fault in model construction, but usable for now.
        attachFrames()
        setSunLocation()
    }
    
    private func attachFrames() {
        first.frame = globe?.findEntity(named: "YawFrame")
        second.frame = globe?.findEntity(named: "PitchFrame")
        third.frame = globe?.findEntity(named: "RollFrame")
        lat.frame = globe?.findEntity(named: "Lat")
        long.frame = globe?.findEntity(named: "Long")
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
        guard let sphere = rootEntity else { return }
        print("  - Got sphere")
        // Get the default transform
        var transform = sphere.transform
        sphere.transform.scale = .zero
        
        // Animate the globe appearing and rotating to its initial longitude
        transform.scale = .zero
        transform.translation = SIMD3(0, 0.7, 0)
        transform.rotation = simd_quatf(angle: -long.radians + 0.5 * .pi, axis: SIMD3(0, 1, 0))
        transform.scale = SIMD3<Float>(1.0, 1.0, 1.0)
        sphere.move(to: transform, relativeTo: sphere.parent, duration: animationDuration)
        print("  - Moving to \(transform)")
    }
}
