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
    
    var cameraPitch: Float { get }
    var cameraYaw: Float { get }
    var cameraTranslation: SIMD3<Float> { get }
    
    func animateEnteringScene()
    func animateLeavingScene()
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
    
    // MARK: - Camera
    
    var cameraRotation: simd_quatf {
        Transform(pitch: cameraPitch, yaw: cameraYaw).rotation
    }
    
    /// Camera transform after applying rotation and translation of the camera relative to the subject at the world origin
    var cameraTransform: Transform {
        return Transform(rotation: cameraRotation, translation: cameraTranslation)
    }

    // MARK: - Animation
    
    var animationDuration: Double { 2 }
    
    func animateEnteringScene() {
        rootEntity?.transform = Transform(scale: .zero)
        rootEntity?.move(to: Transform.identity, relativeTo: rootEntity?.parent, duration: animationDuration)
    }
    
    func animateLeavingScene() {
        let transform = Transform(scale: .zero)
        rootEntity?.move(to: transform, relativeTo: rootEntity?.parent, duration: animationDuration)
    }
    
    func toggleFrames(visible: Bool) {
        rootEntity?.visitChildren { child in
            if ["X", "Y", "Z"].contains(child.name) {
                child.fade(to: visible)
            }
        }
    }
}
