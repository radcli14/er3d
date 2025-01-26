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

    //var globe: Entity?
    var sequence: RotationSequence = YawPitchRollSequence()
    var controlVisibility: ControlVisibility = .bottomButtons
    
    /// The `testBox` is used for debugging the `.nonAR` view, to provide it with pre-existing content that doesn't require the globe to load
    let testBox = ModelEntity(mesh: .generateBox(width: 1, height: 0.1, depth: 1, cornerRadius: 0.05), materials: [SimpleMaterial(color: .blue, isMetallic: true)])

    init(cameraMode: ARView.CameraMode = .nonAR) {
        // Set up the ARView
        arView = ARView(frame: .zero, cameraMode: cameraMode, automaticallyConfigureSession: true)
        //arView.environment.lighting.resource = try! .load(named: "lighting")
        //arView.debugOptions = [.showFeaturePoints, .showWorldOrigin, .showAnchorOrigins, .showSceneUnderstanding, .showPhysics]
        
        // Toggle to the applicable camera mode once the sequence rootEntity is ready
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if self.sequence.rootEntity != nil {
                self.toggleTo(self.arView.cameraMode, onStart: true)
                self.sequence.addGestures(to: self.arView)
                timer.invalidate()
            }
        }
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
        guard let rootEntity = sequence.rootEntity else { return }
        addSceneUnderstanding()
        arView.cameraMode = .ar
        
        arView.scene.anchors.removeAll()
        let arAnchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
        rootEntity.setParent(arAnchor)
        
        arView.scene.anchors.append(arAnchor)
        
        sequence.animateEnteringScene()
    }
    
    private func toggleToStandardView(onStart: Bool = false) {
        print("ER3DRealityViewModel.toggleToStandardView(onStart: Bool = \(onStart))")
        guard let rootEntity = sequence.rootEntity else { return }
        removeSceneUnderstanding()
        arView.cameraMode = .nonAR
        
        arView.scene.anchors.removeAll()
        let standardAnchor = AnchorEntity(world: .zero)
        rootEntity.setParent(standardAnchor)
        standardAnchor.addChild(testBox)
        
        arView.scene.anchors.append(standardAnchor)
        
        arView.scene.addAnchor(standardCameraAnchor)
        
        print("anchor = \(standardAnchor)\nglobe.transform = \(rootEntity.transform)\n\nsphere.transform = \(rootEntity.findEntity(named: "Sphere")!.transform)\n\ntestBox.transform = \(testBox.transform)\n")
        print("Globe is enabled: \(rootEntity.isEnabled)")
        print("Globe parent: \(String(describing: rootEntity.parent?.name)) is anchor \(rootEntity.parent == standardAnchor)")
        print("Anchor children: \(standardAnchor.children.map { $0.name })")
        
        sequence.animateEnteringScene()
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
            sequence.removeTranslationGesture(from: arView)
        } else {
            sequence.addGestures(to: arView)
        }
    }
    
    // MARK: - Latitude and Longitude
    
    /// Sets the rate at which the position of the ship model will change based on a translation gesture when the lat/long controls are active
    let latLongScale: Float = -0.1
    
    /// Latitude angle in degrees
    var lat: Float = 0.0
    
    /// Longitude angle in degrees
    var long: Float = 0.0
    
    func setLatLong(lat: Float, long: Float) {
        self.lat = lat
        self.long = long
    }
    
    /// Resets the latitude and longitude angles to zero (off the cape of Africa)
    func resetLatLong() {
        setLatLong(lat: 0, long: 0)
    }
    
    // MARK: - Constants
    
    private struct Constants {
        static let rad2deg: Float = 180 / .pi
        static let deg2rad: Float = .pi / 180
        static let frameMoveDuration = 0.5
    }
}
