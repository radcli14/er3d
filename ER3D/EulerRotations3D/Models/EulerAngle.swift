//
//  EulerAngle.swift
//  EulerRotations3D
//
//  Created by Eliott Radcliffe on 1/27/25.
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
