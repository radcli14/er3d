//
//  RotationSequence.swift
//  EulerRotations3D
//
//  Created by Eliott Radcliffe on 1/26/25.
//

import Foundation
import RealityKit

/// Protocol requiring that a rotation sequence defines a first, second, and third angle, with a SIMD3 vector state, and a RealityKit root entity
protocol RotationSequence {
    var first: EulerAngle { get set }
    var second: EulerAngle { get set }
    var third: EulerAngle { get set }
    
    var rootEntity: Entity? { get }
    
    func addGestures(to arView: ARView)
    func removeTranslationGesture(from arView: ARView)
    
    func animateEnteringScene()
    
    func setScaleToZero()
}

extension RotationSequence {
    var name: String {
        "\(first.name) → \(second.name) → \(third.name)"
    }
    
    mutating func reset() {
        first.radians = 0
        second.radians = 0
        third.radians = 0
    }
    
    func remove(_ gestures: [any EntityGestureRecognizer]?, from arView: ARView) {
        gestures?.forEach { recognizer in
            remove(recognizer, from: arView)
        }
    }
    
    func remove(_ recognizer: (any EntityGestureRecognizer)?, from arView: ARView) {
        if let recognizer, let idx = arView.gestureRecognizers?.firstIndex(of: recognizer) {
            arView.gestureRecognizers?.remove(at: idx)
        }
    }
}
