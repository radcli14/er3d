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
    
    /// The sphere as the root entity when Earth is visible, or the local geodetic frame when it is not
    var rootEntity: Entity?

    /// The globe which can be referenced when searching for child entities
    private var globe: Entity?
    
    /// The sphere entity on which gestures can be attached, root when Earth is visible.
    /// I need to set the sphere as root because the root was acting as an anchor and ignoring its parent tranform.
    /// This is a fault in model construction, but usable for now.
    private var sphere: Entity?
    
    /// The frame extended out by the Earth radius and ship altitude, which parents the geodetic frame when the Earth is visible
    private var earthRadius: Entity?
    
    /// The frame that is the base for the yaw/pitch/roll frames, root when Earth is not visible
    private var geodetic: Entity?
    
    // MARK: - Initialization
    
    init(earthVisibility: Bool = true) {
        Task {
            await loadGlobe(earthVisibility)
        }
    }
    
    /// Load the globe model asynchronously, set up the sphere and ship with collisions, and add it to the arView
    private func loadGlobe(_ earthVisibility: Bool = true) async {
        globe = try? await Entity(named: "globe", in: Globe.globeBundle)
        sphere = await globe?.findEntity(named: "Sphere")
        earthRadius = await globe?.findEntity(named: "EarthRadius")
        geodetic = await globe?.findEntity(named: "LocalGeodeticFrame")
        
        // Set the root dependent on the initial Earth visibility
        rootEntity = earthVisibility ? sphere : geodetic
        
        attachFrames()
        setSunLocation()
    }
    
    // MARK: - Frames
    
    private func attachFrames() {
        first.frame = globe?.findEntity(named: "YawFrame")
        second.frame = globe?.findEntity(named: "PitchFrame")
        third.frame = globe?.findEntity(named: "RollFrame")
        lat.frame = globe?.findEntity(named: "Lat")
        long.frame = globe?.findEntity(named: "Long")
    }
    
    // MARK: - Sun
    
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
    
    // MARK: - Camera
    
    /// Tilt angle of the camera, negative pitch is tilting downward toward the subject
    var cameraPitch: Float {
        switch rootEntity {
        case geodetic: return -0.7
        default: return -0.1
        }
    }
    
    /// Rotation angle of the camera about the vertical axis
    var cameraYaw: Float {
        switch rootEntity {
        case geodetic: return 0.47
        default: return 0
        }
    }
    
    /// Position of the camera relative to the subject at the world origin, positive-y is vertical, positive-z is backward
    var cameraTranslation: SIMD3<Float> {
        switch rootEntity {
        case geodetic: return SIMD3<Float>(0.4, 1.3, 0.8)
        default: return SIMD3<Float>(0, 1.2, 1)
        }
    }
    
    // MARK: - Animation
    
    func animateEnteringScene() {
        if rootEntity == sphere {
            animateEarthEnteringScene()
        } else {
            geodetic?.move(to: baseFrameTransformWhenEarthRemoved, relativeTo: geodetic?.parent, duration: animationDuration)
        }
    }
    
    func resetRootEntityPosition() {
        //var transform: Transform
        let transform = switch rootEntity {
        case geodetic: baseFrameTransformWhenEarthRemoved
        default: earthTransformWhenEntering
        }
        rootEntity?.move(to: transform, relativeTo: rootEntity?.parent, duration: animationDuration)
    }
    
    var earthTransformWhenEntering: Transform {
        Transform(
            scale: .one,
            rotation: simd_quatf(angle: -long.radians + 0.5 * .pi, axis: SIMD3(0, 1, 0)),
            translation: SIMD3(0, 0.7, 0)
        )
    }
    
    /// Animate the globe appearing and rotating to its initial longitude
    func animateEarthEnteringScene() {
        print("YawPitchRollSequence.animateEnteringScene()")
        sphere?.transform.scale = .zero
        //guard let sphere else { return }
        /*print("  - Got sphere")
        // Get the default transform
        var transform = sphere.transform
        sphere.transform.scale = .zero
        
        // Animate the globe appearing and rotating to its initial longitude
        transform.scale = .zero
        transform.translation = SIMD3(0, 0.7, 0)
        transform.rotation = simd_quatf(angle: -long.radians + 0.5 * .pi, axis: SIMD3(0, 1, 0))
        transform.scale = SIMD3<Float>(1.0, 1.0, 1.0)*/
        sphere?.move(to: earthTransformWhenEntering, relativeTo: sphere?.parent, duration: animationDuration)
        print("  - Moving to \(earthTransformWhenEntering)")
    }
    
    func animateEarthLeavingScene() {
        let transform = Transform(scale: .zero)
        sphere?.move(to: transform, relativeTo: sphere?.parent, duration: animationDuration)
    }
    
    // MARK: - Earth Visibility
    
    private var baseTransformWhenEarthIsVisible: Transform {
        Transform(
            scale: .one,
            rotation: Transform(yaw: -.pi/2).rotation,
            translation: .zero
        )
    }
    
    /// Add the Earth when the user toggle's Earth visibility to on
    func addEarth(parent: Entity) {
        // Child the sphere root entity to the parent from the scene, and animate it returning
        sphere?.setParent(parent)

        // We set the geodetic frame initially to be a child of the scene parent, to preserve its existing position prior to animation
        self.geodetic?.setParent(parent, preservingWorldTransform: true)
        
        // Initiate the Earth growing back into the world
        animateEarthEnteringScene()
        
        // Animate the ship's position on the surface of the Earth.
        // This must be on some delay, because initially the globe scale is zero.
        // If the animation starts instantly, a divide-by-zero occurs, and the ship disappears.
        // The time interval I selected was through trial and error to get a smooth transition.
        Timer.scheduledTimer(withTimeInterval: 0.25 * animationDuration, repeats: false) { timer in
            self.geodetic?.setParent(self.earthRadius, preservingWorldTransform: true)
            self.geodetic?.move(to: self.baseTransformWhenEarthIsVisible, relativeTo: self.earthRadius, duration: 0.75 * self.animationDuration)
        }
        
        rootEntity = sphere
    }
    
    private var baseFrameTransformWhenEarthRemoved: Transform {
        Transform(
            scale: 3.14 * .one,
            rotation: Transform(pitch: .pi/2, yaw: .pi/2, roll: 0).rotation,
            translation: SIMD3(0, 0.7, 0)
        )
    }
    
    /// Remove the Earth when the user toggle's Earth visibility to off
    func removeEarth(parent: Entity) {
        // Make the Earth entity depart from the scene
        animateEarthLeavingScene()
        
        // Child the geodetic frame that is the base of the ship to the parent in the scene
        geodetic?.setParent(parent, preservingWorldTransform: true)

        // Animate the base frame going to its location just above the ground
        geodetic?.move(to: baseFrameTransformWhenEarthRemoved, relativeTo: parent, duration: animationDuration)

        Timer.scheduledTimer(withTimeInterval: animationDuration, repeats: false) { _ in
            self.sphere?.removeFromParent()
        }
        
        rootEntity = geodetic
    }
}
