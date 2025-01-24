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
import Globe

@Observable class ER3DRealityViewModel {
    var arView: ARView

    var globe: Entity?
    var controlVisibility: ControlVisibility = .bottomButtons
    
    /// The `testBox` is used for debugging the `.nonAR` view, to provide it with pre-existing content that doesn't require the globe to load
    let testBox = ModelEntity(mesh: .generateBox(width: 1, height: 0.1, depth: 1, cornerRadius: 0.05), materials: [SimpleMaterial(color: .blue, isMetallic: true)])

    init(cameraMode: ARView.CameraMode = .nonAR) {
        // Set up the ARView
        arView = ARView(frame: .zero, cameraMode: cameraMode, automaticallyConfigureSession: true)
        //arView.environment.lighting.resource = try! .load(named: "lighting")
        //arView.debugOptions = [.showFeaturePoints, .showWorldOrigin, .showAnchorOrigins, .showSceneUnderstanding, .showPhysics]
        
        // Load the globe model asynchronously
        Task {
            await loadGlobe()
            toggleTo(cameraMode, onStart: true)
        }
    }
    
    // MARK: - Initialization
    
    /// Load the globe model asynchronously, set up the sphere and ship with collisions, and add it to the arView
    private func loadGlobe() async {
        globe = try? await Entity(named: "globe", in: Globe.globeBundle)
        setSunLocation()
        setInitialLatLong()
        addGlobeGestures()
        setGlobeScaleToZero()
    }
    
    /// The globe should initially be invisible (zero scale) before entering the scene
    private func setGlobeScaleToZero() {
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
        print("ER3DRealityViewModel.setSunLocation(): azimuth = \(azimuth * Constants.rad2deg) deg, elevation = \(elevation * Constants.rad2deg) deg")
        globe?.findEntity(named: "SunAzimuth")?.transform.rotation = azRotation
        globe?.findEntity(named: "SunElevation")?.transform.rotation = elRotation
    }
    
    /// Animate the globe appearing and rotating to its initial longitude
    private func animateGlobeEnteringScene() {
        print("ER3DRealityViewModel.animateGlobeEnteringScene()")
        guard let sphere = globe?.findEntity(named: "Sphere") else { return }
        print("  - Got sphere")
        // Get the default transform
        var transform = sphere.transform
        
        // Animate the globe appearing and rotating to its initial longitude
        globe?.transform.translation = .zero
        transform.translation = SIMD3(0, 0.7, 0)
        transform.rotation = simd_quatf(angle: (-long+90) * Constants.deg2rad, axis: SIMD3(0, 1, 0))
        transform.scale = SIMD3<Float>(1.0, 1.0, 1.0)
        sphere.move(to: transform, relativeTo: arView.scene.anchors.first!, duration: 2.0)
        print("  - Moving to \(transform)")
    }
    
    // MARK: - AR View Modes
    
    func toggleTo(_ cameraMode: ARView.CameraMode, onStart: Bool = false) {
        switch cameraMode {
        case .ar: toggleToArView(onStart: onStart)
        case .nonAR: toggleToStandardView(onStart: onStart)
        default: fatalError("Tried to toggle to a cameraMode that is not handled")
        }
    }
    
    private func toggleToArView(onStart: Bool = false) {
        print("ER3DRealityViewModel.toggleToArView(onStart: Bool = \(onStart))")
        addSceneUnderstanding()
        arView.cameraMode = .ar
        
        arView.scene.anchors.removeAll()
        let arAnchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
        globe?.setParent(arAnchor)
        
        arView.scene.anchors.append(arAnchor)
        
        animateGlobeEnteringScene()
    }
    
    private func toggleToStandardView(onStart: Bool = false) {
        print("ER3DRealityViewModel.toggleToStandardView(onStart: Bool = \(onStart))")
        removeSceneUnderstanding()
        arView.cameraMode = .nonAR
        
        arView.scene.anchors.removeAll()
        let standardAnchor = AnchorEntity(world: .zero)
        globe?.setParent(standardAnchor)
        standardAnchor.addChild(testBox)
        
        arView.scene.anchors.append(standardAnchor)
        
        arView.scene.addAnchor(standardCameraAnchor)
        
        print("anchor = \(standardAnchor)\nglobe.transform = \(globe!.transform)\n\nsphere.transform = \(globe!.findEntity(named: "Sphere")!.transform)\n\ntestBox.transform = \(testBox.transform)\n")
        print("Globe is enabled: \(globe!.isEnabled)")
        print("Globe parent: \(String(describing: globe!.parent?.name)) is anchor \(globe!.parent == standardAnchor)")
        print("Anchor children: \(standardAnchor.children.map { $0.name })")
        
        animateGlobeEnteringScene()
    }
    
    /// Camera anchor to be used when in `.nonAR` mode
    private var standardCameraAnchor: AnchorEntity {
        let cameraEntity = PerspectiveCamera()
        cameraEntity.camera.fieldOfViewInDegrees = 60
        var cameraTransform = Transform(pitch: -0.1)
        cameraTransform.translation = SIMD3<Float>(0, 1.2, 1)
        let standardCameraAnchor = AnchorEntity(world: cameraTransform.matrix)
        standardCameraAnchor.addChild(cameraEntity)
        return standardCameraAnchor
    }
    
    private let sceneUnderstandingOptions: [ARView.Environment.SceneUnderstanding.Options] = [
        .receivesLighting, .occlusion, .physics
    ]
    
    /// Adds Scene Understanding to the `arView`, so that the coins bounce off the ground, tables occlude the model, etc
    func addSceneUnderstanding() {
        for option in sceneUnderstandingOptions {
            arView.environment.sceneUnderstanding.options.insert(option)
        }
    }
    
    /// Removes Scene Understanding from the `arView`
    func removeSceneUnderstanding() {
        for option in sceneUnderstandingOptions {
            arView.environment.sceneUnderstanding.options.remove(option)
        }
    }
    
    // MARK: - State Changes
    
    /// When the user toggles to lat/long control, remove the ARView gestures, or add them back in when toggling away
    func handleControlVisibilityChange() {
        if controlVisibility == .latLongControls {
            removeGlobeTranslationGesture()
        } else {
            addGlobeGestures()
        }
    }
    
    // MARK: - Gestures
    
    private func remove(_ gestures: [any EntityGestureRecognizer]?) {
        gestures?.forEach { recognizer in
            remove(recognizer)
        }
    }
    
    private func remove(_ recognizer: (any EntityGestureRecognizer)?) {
        if let recognizer, let idx = arView.gestureRecognizers?.firstIndex(of: recognizer) {
            arView.gestureRecognizers?.remove(at: idx)
        }
    }
    
    /// The translation gesture on the globe touch cylinder, separated from the other gestures becasue we will add and remove it depending on if the user is viewing latitude and longitude
    var globeTranslationGesture: EntityGestureRecognizer?
    
    /// The two finger gestures for rotation and scale of the globe sphere
    var globeRotationAndScaleGestures: [any EntityGestureRecognizer]?

    /// Set up the sphere collisions and gestures which allow you to move, rotate, and scale the globe
    func addGlobeGestures() {
        print("ER3DRealityViewModel.addGlobeGestures()")
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
    func removeGlobeTranslationGesture() {
        print("ER3DRealityViewModel.removeGlobeTranslationGesture()")
        remove(globeTranslationGesture)
        globeTranslationGesture = nil
    }
    
    // MARK: - Euler Angles

    /// Rotation angle about the Yaw-Z axis in radians
    var yaw: Float = 0.0 {
        didSet {
            guard let frame = globe?.findEntity(named: "YawFrame") else { return }
            frame.move(to: Transform(roll: yaw), relativeTo: frame.parent, duration: Constants.frameMoveDuration)
        }
    }
    
    /// Rotation angle about the Pitch-Y axis in radians
    var pitch: Float = 0.0 {
        didSet {
            guard let frame = globe?.findEntity(named: "PitchFrame") else { return }
            frame.move(to: Transform(yaw: pitch), relativeTo: frame.parent, duration: Constants.frameMoveDuration)
        }
    }
    
    /// Rotation angle about the Roll-X axis in radians
    var roll: Float = 0.0 {
        didSet {
            guard let frame = globe?.findEntity(named: "RollFrame") else { return }
            frame.move(to: Transform(pitch: roll), relativeTo: frame.parent, duration: Constants.frameMoveDuration)
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
        static let frameMoveDuration = 0.5
    }
}
