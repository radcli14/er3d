//
//  SceneKit+Extensions.swift
//  ER3D
//
//  Created by Eliott Radcliffe on 5/31/24.
//

import SceneKit

extension SCNVector3 {
    static let zero = SCNVector3(0, 0, 0)
}

extension SCNQuaternion {
    static let ninetyDegAboutY = SCNQuaternion(x: 0, y: sin(0.25*Float.pi), z: 0, w: cos(0.25*Float.pi))
    static let ninetyDegAboutMinusZ = SCNQuaternion(x: -sin(0.25*Float.pi), y: 0, z: 0, w: cos(0.25*Float.pi))
}
