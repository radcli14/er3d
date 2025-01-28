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
}
