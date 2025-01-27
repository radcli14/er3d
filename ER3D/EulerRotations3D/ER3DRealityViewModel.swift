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
    var controlVisibility: ControlVisibility = .bottomButtons
    
    // MARK: - Initialization
    
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
    
    // MARK: - RotationSequence
    
    /// Specify the Euler sequence model that will be presented to the user
    var selectedSequence: EulerSequence = .yawPitchRoll
    private var yawPitchRollSequence = YawPitchRollSequence()
    private var processionNutationSpinSequence = ProcessionNutationSpinSequence()
    var sequence: RotationSequence {
        get {
            switch selectedSequence {
            case .yawPitchRoll: yawPitchRollSequence
            case .processionNutationSpin: processionNutationSpinSequence
            }
        }
        set {
            if newValue is YawPitchRollSequence {
                selectedSequence = .yawPitchRoll
            } else if newValue is ProcessionNutationSpinSequence {
                selectedSequence = .processionNutationSpin
            } else {
                fatalError("Unsupported RotationSequence type")
            }
        }
    }
    
    /// If the globe sequence is active, then provide it as a `HasLatLong` type
    var latLongSequence: HasLatLong? {
        sequence as? HasLatLong
    }
    
    func toggleTo(_ eulerSequence: EulerSequence) {
        let oldRootEntity = sequence.rootEntity
        oldRootEntity?.removeFromParent()
        selectedSequence = eulerSequence
        toggleTo(arView.cameraMode)
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
    
    /// The `testBox` is used for debugging the `.nonAR` view, to provide it with pre-existing content that doesn't require the globe to load
    private let testBox = ModelEntity(mesh: .generateBox(width: 1, height: 0.1, depth: 1, cornerRadius: 0.05), materials: [SimpleMaterial(color: .blue, isMetallic: true)])
    
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

    func handleDragGesture(at touchPoint: CGPoint) {
        if var latLongSequence, controlVisibility == .latLongControls, let hit = arView.hitTest(touchPoint).first, hit.entity.name == "Sphere" {
            latLongSequence.setLatLong(given: hit)
        }
    }
    
    /// Resets the latitude and longitude angles to zero (off the cape of Africa)
    func resetLatLong(_ stateToReset: String) {
        if var latLongSequence {
            switch stateToReset {
            case "Latitude": latLongSequence.lat.radians = 0
            case "Longitude": latLongSequence.long.radians = 0
            default: latLongSequence.setLatLong(lat: 0, long: 0)
            }
        }
    }
}
