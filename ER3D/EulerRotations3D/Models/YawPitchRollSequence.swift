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
    var rootEntity: Entity?

    // MARK: - Initialization
    
    init() {
        Task {
            await loadGlobe()
        }
    }
    
    /// Load the globe model asynchronously, set up the sphere and ship with collisions, and add it to the arView
    private func loadGlobe() async {
        rootEntity = try? await Entity(named: "globe", in: Globe.globeBundle)
        attachFrames()
        setSunLocation()
        animateEnteringScene()
    }
    
    private func attachFrames() {
        first.frame = rootEntity?.findEntity(named: "YawFrame")
        second.frame = rootEntity?.findEntity(named: "PitchFrame")
        third.frame = rootEntity?.findEntity(named: "RollFrame")
        lat.frame = rootEntity?.findEntity(named: "Lat")
        long.frame = rootEntity?.findEntity(named: "Long")
    }
    
    /// The globe should initially be invisible (zero scale) before entering the scene
    func setScaleToZero() {
        rootEntity?.findEntity(named: "Sphere")?.transform.scale = SIMD3(0.0, 0.0, 0.0)
    }
    
    /// Set the angular position of the sun based on the date and time of day
    private func setSunLocation() {
        let azimuth = Date.now.solarTimeOffsetAngleRadians
        let azRotation = simd_quatf(angle: azimuth, axis: SIMD3(0, 0, -1)) // negative ECEF-Z, travels westward for increasing angle
        let elevation = Date.now.solarElevationAngleRadians
        let elRotation = simd_quatf(angle: elevation, axis: SIMD3(0, 1, 0))
        print("YawPitchRollSequence.setSunLocation(): azimuth = \(azimuth * 180 / .pi) deg, elevation = \(elevation * 180 / .pi) deg")
        rootEntity?.findEntity(named: "SunAzimuth")?.transform.rotation = azRotation
        rootEntity?.findEntity(named: "SunElevation")?.transform.rotation = elRotation
    }
    
    /// Animate the globe appearing and rotating to its initial longitude
    func animateEnteringScene() {
        print("YawPitchRollSequence.animateEnteringScene()")
        guard let sphere = rootEntity?.findEntity(named: "Sphere") else { return }
        print("  - Got sphere")
        // Get the default transform
        var transform = sphere.transform
        
        // Animate the globe appearing and rotating to its initial longitude
        //rootEntity?.transform.translation = .zero
        transform.scale = .zero
        transform.translation = SIMD3(0, 0.7, 0)
        transform.rotation = simd_quatf(angle: -long.radians + 0.5 * .pi, axis: SIMD3(0, 1, 0))
        transform.scale = SIMD3<Float>(1.0, 1.0, 1.0)
        //sphere.move(to: transform, relativeTo: sphere.parent, duration: 2.0)
        sphere.transform = transform
        print("  - Moving to \(transform)")
    }
}
