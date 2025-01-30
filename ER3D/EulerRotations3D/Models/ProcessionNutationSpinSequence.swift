//
//  ProcessionNutationSpinSequence.swift
//  EulerRotations3D
//
//  Created by Eliott Radcliffe on 1/27/25.
//

import Foundation
import RealityKit
import Globe

class ProcessionNutationSpinSequence: RotationSequence {
    var first: EulerAngle = .procession
    
    var second: EulerAngle = .nutation
    
    var third: EulerAngle = .spin
    
    var rootEntity: Entity?
    
    init() {
        Task {
            await rootEntity = try? Entity(named: "ProcessionNutationSpin", in: Globe.globeBundle)
            attachFrames()
        }
    }
    
    func attachFrames() {
        first.frame = rootEntity?.findEntity(named: "Procession")
        second.frame = rootEntity?.findEntity(named: "Nutation")
        third.frame = rootEntity?.findEntity(named: "Spin")
    }
    
    // MARK: - Camera
    
    /// Tilt angle of the camera, negative pitch is tilting downward toward the subject
    let cameraPitch: Float = -0.4
    
    /// Rotation angle of the camera about the vertical axis
    let cameraYaw: Float = 0.61
    
    /// Position of the camera relative to the subject at the world origin, positive-y is vertical, positive-z is backward
    let cameraTranslation = SIMD3<Float>(2.0, 1.75, 2.9)
}
