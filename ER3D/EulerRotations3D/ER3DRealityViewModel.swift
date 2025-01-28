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
    
    init(with settings: SettingsContent.ViewModel = SettingsContent.ViewModel()) {
        // Set up the ARView based on stored settings
        arView = ARView(frame: .zero, cameraMode: settings.cameraMode, automaticallyConfigureSession: true)
        selectedSequence = settings.sequence
        //arView.environment.lighting.resource = try! .load(named: "lighting")
        //arView.debugOptions = [.showFeaturePoints, .showWorldOrigin, .showAnchorOrigins, .showSceneUnderstanding, .showPhysics]
        
        // Toggle to the applicable camera mode once the sequence rootEntity is ready
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if self.sequence.rootEntity != nil {
                self.toggleTo(self.arView.cameraMode, onStart: true)
                timer.invalidate()
            }
        }
    }
    
    // MARK: - RotationSequence
    
    /// Specify the Euler sequence model that will be presented to the user
    var selectedSequence: EulerSequence
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
    
    /// The `floor` is used as a common base platform for the `rootEntity` of any rotation sequence, and where we attach gestures
    private let floor = ModelEntity(mesh: .generateBox(width: 1, height: 0.01, depth: 1, cornerRadius: 0.005), materials: [SimpleMaterial(color: .blue, isMetallic: true)])
    
    func toggleTo(_ cameraMode: ARView.CameraMode, onStart: Bool = false) {
        removeAllGestures()
        switch cameraMode {
        case .ar: toggleToArView(onStart: onStart)
        case .nonAR: toggleToStandardView(onStart: onStart)
        default: fatalError("Tried to toggle to a cameraMode that is not handled")
        }
        addGestures()
    }
    
    private func toggleToArView(onStart: Bool = false) {
        print("ER3DRealityViewModel.toggleToArView(onStart: Bool = \(onStart))")
        guard let rootEntity = sequence.rootEntity else { return }
        addSceneUnderstanding()
        arView.cameraMode = .ar
        
        arView.scene.anchors.removeAll()
        let arAnchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
        floor.setParent(arAnchor)
        rootEntity.setParent(floor)

        arView.scene.anchors.append(arAnchor)
        
        //sequence.animateEnteringScene()
    }
    
    private func toggleToStandardView(onStart: Bool = false) {
        print("ER3DRealityViewModel.toggleToStandardView(onStart: Bool = \(onStart))")
        guard let rootEntity = sequence.rootEntity else { return }
        removeSceneUnderstanding()
        arView.cameraMode = .nonAR
        
        arView.scene.anchors.removeAll()
        let standardAnchor = AnchorEntity(world: .zero)
        floor.setParent(standardAnchor)
        rootEntity.setParent(floor)

        arView.scene.anchors.append(standardAnchor)
        
        arView.scene.addAnchor(standardCameraAnchor)
        
        print("anchor = \(standardAnchor)\nglobe.transform = \(rootEntity.transform)\n\nsphere.transform = \(rootEntity.findEntity(named: "Sphere")!.transform)\n\ntestBox.transform = \(floor.transform)\n")
        print("Globe is enabled: \(rootEntity.isEnabled)")
        print("Globe parent: \(String(describing: rootEntity.parent?.name)) is anchor \(rootEntity.parent == standardAnchor)")
        print("Anchor children: \(standardAnchor.children.map { $0.name })")
        
        //sequence.animateEnteringScene()
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
    
    // MARK: - Gestures
    
    func remove(_ gestures: [any EntityGestureRecognizer]?) {
        gestures?.forEach { recognizer in
            remove(recognizer)
        }
    }
    
    func remove(_ recognizer: (any EntityGestureRecognizer)?) {
        if let recognizer, let idx = arView.gestureRecognizers?.firstIndex(of: recognizer) {
            arView.gestureRecognizers?.remove(at: idx)
        }
    }
    
    /// The translation gesture on the globe touch cylinder, separated from the other gestures becasue we will add and remove it depending on if the user is viewing latitude and longitude
    var translationGesture: EntityGestureRecognizer?
    
    /// The two finger gestures for rotation and scale of the globe sphere
    var rotationAndScaleGestures: [any EntityGestureRecognizer]?

    /// Set up the sphere collisions and gestures which allow you to move, rotate, and scale the globe
    func addGestures() {
        print("ER3DRealityViewModel.addGestures()")
        print("  - Generating collision shapes for the floor, recursively to children")
        floor.generateCollisionShapes(recursive: true)

        if translationGesture == nil {
            print("  - Installing translation gesture")
            translationGesture = arView.installGestures(.translation, for: floor).first
        }
        
        if rotationAndScaleGestures == nil {
            print("  - Installing rotation and scale gestures")
            rotationAndScaleGestures = arView.installGestures([.rotation, .scale], for: floor)
        }
    }
    
    /// Remove all of the entity gestures, use when transitioning between models
    func removeAllGestures() {
        remove(translationGesture)
        translationGesture = nil
        remove(rotationAndScaleGestures)
        rotationAndScaleGestures = nil
    }
    
    /// Remove the globe translation gestures to enable separate gestures to modify latitude and longitude
    func removeTranslationGesture() {
        print("ER3DRealityViewModel.removeTranslationGesture()")
        remove(translationGesture)
        translationGesture = nil
    }
    
    // MARK: - State Changes
    
    /// When the user toggles to lat/long control, remove the ARView gestures, or add them back in when toggling away
    func handleControlVisibilityChange() {
        if controlVisibility == .latLongControls {
            removeTranslationGesture()
        } else {
            addGestures()
        }
    }
    
    // MARK: - Latitude and Longitude

    func handleDragGesture(at touchPoint: CGPoint) {
        if var latLongSequence, controlVisibility == .latLongControls,
            let hit = arView.hitTest(touchPoint).first(where: { $0.entity.name == "Sphere" }) {
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
