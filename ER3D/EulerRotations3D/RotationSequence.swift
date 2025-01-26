//
//  RotationSequence.swift
//  EulerRotations3D
//
//  Created by Eliott Radcliffe on 1/26/25.
//

import Foundation
import RealityKit

/// Defines the name, symbol, and axis associated with this Euler angle
struct EulerAngle {
    let name: String
    let symbol: String
    let axis: SIMD3<Float>
    var angle: Float = 0 {
        didSet {
            guard let frame else { return }
            let rotation = simd_quatf(angle: angle, axis: axis)
            frame.move(to: Transform(rotation: rotation), relativeTo: frame.parent, duration: 0.5)
        }
    }
    var frame: Entity?

    // MARK: - Yaw → Pitch → Roll
    
    static let yaw = Self(name: "Yaw", symbol: "ψ", axis: SIMD3(0, 0, 1))
    static let pitch = Self(name: "Pitch", symbol: "𝜃", axis: SIMD3(0, 1, 0))
    static let roll = Self(name: "Roll", symbol: "φ", axis: SIMD3(1, 0, 0))
    
    // MARK: - Procession → Nutation → Spin
    
    static let procession = Self(name: "Procession", symbol: "φ", axis: SIMD3(0, 0, 1))
    static let nutation = Self(name: "Nutation", symbol: "𝜃", axis: SIMD3(1, 0, 0))
    static let spin = Self(name: "Spin", symbol: "ψ", axis: SIMD3(0, 0, 1))
}

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
        first.angle = 0
        second.angle = 0
        third.angle = 0
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
