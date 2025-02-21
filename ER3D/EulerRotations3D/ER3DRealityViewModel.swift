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
    var controlVisibility: ControlVisibility = .bottomButtons
    var grid: Entity?
    
    /// Number of actions the user has taken in the app, used to control when a review gets requesed
    var actionCount = 0
    
    // MARK: - Initialization
    
    init(with settings: SettingsContent.ViewModel = SettingsContent.ViewModel()) {
        // Set up the ARView based on stored settings
        arView = ARView(frame: .zero, cameraMode: settings.cameraMode, automaticallyConfigureSession: true)
        selectedSequence = settings.sequence
        //arView.environment.lighting.resource = try! .load(named: "lighting")
        //arView.debugOptions = [.showFeaturePoints, .showWorldOrigin, .showAnchorOrigins, .showSceneUnderstanding, .showPhysics]
        
        // Provide the initial Earth visibility to the YawPitchRollSequence
        yawPitchRollSequence = YawPitchRollSequence(earthVisibility: settings.earthVisibility)

        // Setup the camera with initial position
        standardCamera.camera.fieldOfViewInDegrees = 60
        standardCamera.camera.near = 0.1
        standardCamera.camera.far = 50
        standardCamera.setParent(standardAnchor)
        repositionStandardCamera()
        
        Task {
            await grid = try? Entity(named: "Grid", in: Globe.globeBundle)
            await grid?.setParent(standardAnchor)
        }
        
        // Toggle to the applicable camera mode once the sequence rootEntity is ready
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if self.sequence.rootEntity != nil {
                self.toggleTo(self.arView.cameraMode, onStart: true)
                self.toggleFrames(visible: settings.frameVisibility)
                timer.invalidate()
            }
        }
    }
    
    // MARK: - RotationSequence
    
    /// Specify the Euler sequence model that will be presented to the user
    var selectedSequence: EulerSequence
    private var yawPitchRollSequence: YawPitchRollSequence
    private var processionNutationSpinSequence = ProcessionNutationSpinSequence()
    private var availableSequences: [RotationSequence] { [yawPitchRollSequence, processionNutationSpinSequence] }
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
        actionCount += 1
        removeAllGestures()
        let oldRootEntity = sequence.rootEntity
        sequence.animateLeavingScene()
        Timer.scheduledTimer(withTimeInterval: sequence.animationDuration, repeats: false) { timer in
            oldRootEntity?.removeFromParent()
            self.selectedSequence = eulerSequence
            self.parentRootEntityToFloor()
            self.sequence.animateEnteringScene()
            self.repositionStandardCamera()
            self.addGestures()
        }
        resetFloorPosition()
    }
    
    // MARK: - AR View Modes
    
    private static let anchorSize: Float = 0.2
    var anchorBounds = SIMD2<Float>(anchorSize, anchorSize)
    
    /// The `floor` is used as a common base platform for the `rootEntity` of any rotation sequence, and where we attach gestures
    private let floor = ModelEntity(
        mesh: .generateCylinder(height: 0, radius: 0.5 * anchorSize),
        materials: [SimpleMaterial(color: .clear, isMetallic: true)]
    )
    
    private func resetFloorPosition() {
        floor.move(to: .identity, relativeTo: floor.parent, duration: sequence.animationDuration)
    }
    
    /// Re-anchor the floor, and animate from its old position to a new position
    private func setAnchor(to newAnchor: AnchorEntity) {
        floor.removeFromParent(preservingWorldTransform: true)
        arView.scene.anchors.removeAll()
        arView.scene.anchors.append(newAnchor)
        floor.setParent(newAnchor, preservingWorldTransform: true)
        resetFloorPosition()
    }
    
    private func parentRootEntityToFloor() {
        sequence.rootEntity?.setParent(floor, preservingWorldTransform: true)
        sequence.resetRootEntityPosition()
    }
    
    func toggleTo(_ cameraMode: ARView.CameraMode, onStart: Bool = false) {
        actionCount += 1
        removeAllGestures()
        switch cameraMode {
        case .ar: toggleToArView(onStart: onStart)
        case .nonAR: toggleToStandardView(onStart: onStart)
        default: fatalError("Tried to toggle to a cameraMode that is not handled")
        }
        addGestures()
    }
    
    private var arAnchor: AnchorEntity {
        guard let raycastResult = arView.raycast(
                from: arView.center,
                allowing: .estimatedPlane,
                alignment: .horizontal
        ).first else {
            print("Getting arAnchor position using standard plane detection method")
            return AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: anchorBounds))
        }
        
        let hitPosition = raycastResult.worldTransform
        print("Getting arAnchor using raycast at \(hitPosition)")
        return AnchorEntity(world: hitPosition)
    }
    
    private func toggleToArView(onStart: Bool = false) {
        print("ER3DRealityViewModel.toggleToArView(onStart: Bool = \(onStart))")
        addSceneUnderstanding()
        arView.cameraMode = .ar
        
        setAnchor(to: arAnchor)
        parentRootEntityToFloor()

        sequence.animateEnteringScene()
    }
    
    /// Anchor
    private let standardAnchor = AnchorEntity(world: .zero)
    
    /// Perspective camera with specified field of view
    var standardCamera = PerspectiveCamera()
    
    private func repositionStandardCamera() {
        print("repositionStandardCamera to \(sequence.cameraTransform) with sequence \(sequence)")
        standardCamera.move(
            to: sequence.cameraTransform,
            relativeTo: standardAnchor,
            duration: sequence.animationDuration
        )
    }
    
    
    private func toggleToStandardView(onStart: Bool = false) {
        print("ER3DRealityViewModel.toggleToStandardView(onStart: Bool = \(onStart))")
        removeSceneUnderstanding()
        arView.cameraMode = .nonAR
        
        setAnchor(to: standardAnchor)
        parentRootEntityToFloor()

        repositionStandardCamera()

        sequence.animateEnteringScene()
    }
    
    // MARK: - Scene
    
    /// Action when the user taps the reset button from the `BottomButtons`
    func resetScene() {
        actionCount += 1
        if arView.cameraMode == .ar {
            setAnchor(to: arAnchor)
        }
        resetFloorPosition()
        sequence.resetRootEntityPosition()
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
        actionCount += 1
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
        actionCount += 1
        if var latLongSequence {
            switch stateToReset {
            case "Latitude": latLongSequence.lat.radians = 0
            case "Longitude": latLongSequence.long.radians = 0
            default: latLongSequence.setLatLong(lat: 0, long: 0)
            }
        }
    }
    
    // MARK: - Visibility
    
    func toggleFrames(visible: Bool) {
        actionCount += 1
        availableSequences.forEach { sequence in
            sequence.toggleFrames(visible: visible)
        }
    }
    
    func toggleEarth(visible: Bool) {
        actionCount += 1
        switch visible {
        case true: yawPitchRollSequence.addEarth(parent: floor)
        case false: yawPitchRollSequence.removeEarth(parent: floor)
        }
        if arView.cameraMode == .nonAR {
            resetFloorPosition()
        }
        repositionStandardCamera()
    }
}
