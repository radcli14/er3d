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
    var radians: Float = 0 {
        didSet {
            guard let frame else { return }
            let rotation = simd_quatf(angle: radians, axis: axis)
            frame.move(to: Transform(rotation: rotation), relativeTo: frame.parent, duration: 0.5)
        }
    }
    var degrees: Float {
        get {
            radians * Constants.rad2deg
        }
        set {
            radians = newValue * Constants.deg2rad
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
    
    // MARK: - Latitude and Longitude
    
    static let latitude = Self(name: "Latitude", symbol: "", axis: SIMD3(0, -1, 0)) // Negative sign about axis to right of globe
    static let longitude = Self(name: "Longitude", symbol: "", axis: SIMD3(0, 0, 1))
    
    // MARK: - Constants
    
    private struct Constants {
        static let deg2rad: Float = .pi / 180
        static let rad2deg: Float = 180 / .pi
    }
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

protocol HasLatLong: RotationSequence {
    var lat: EulerAngle { get set }
    var long: EulerAngle { get set }
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

extension HasLatLong {
    mutating func setLatLong(given hit: CollisionCastHit) {
        // Convert the hit position in the world to one that is local to the sphere
        let hitPositionLocal = hit.entity.convert(position: hit.position, from: nil)
        
        // Perform calculations for radius, latitude, and longitude
        let radius = length(hitPositionLocal)
        lat.radians = asin(hitPositionLocal.y / radius / 0.8)  // Strangely, angles were getting clamped at [-45, 45] deg, dividing through seems to help, but I don't have a good explanation
        long.radians = atan2(hitPositionLocal.z, -hitPositionLocal.x)
    }
    
    mutating func setLatLong(lat: Float, long: Float) {
        self.lat.radians = lat
        self.long.radians = long
    }
    
    mutating func resetLatLong() {
        setLatLong(lat: 0, long: 0)
    }
}
