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
    static let fortyFiveDegAboutX = SCNQuaternion(x: .halfSinFortyFiveDeg, y: 0, z: 0, w: .halfCosFortyFiveDeg)
    static let ninetyDegAboutMinusX = SCNQuaternion(x: .halfSinNinetyDeg, y: 0, z: 0, w: -.halfCosNinetyDeg)
    static let ninetyDegAboutY = SCNQuaternion(x: 0, y: .halfSinNinetyDeg, z: 0, w: .halfCosNinetyDeg)
    static let ninetyDegAboutMinusY = SCNQuaternion(x: 0, y: .halfSinNinetyDeg, z: 0, w: -.halfCosNinetyDeg)
    static let ninetyDegAboutZ = SCNQuaternion(x: 0, y: 0, z: .halfSinNinetyDeg, w: .halfCosNinetyDeg)
    static let ninetyDegAboutMinusZ = SCNQuaternion(x: 0, y: 0, z: .halfSinNinetyDeg, w: -.halfCosNinetyDeg)
}

extension Float {
    static let halfSinFortyFiveDeg = sin(0.125 * Float.pi)
    static let halfCosFortyFiveDeg = cos(0.125 * Float.pi)
    static let halfSinNinetyDeg = sin(0.25 * Float.pi)
    static let halfCosNinetyDeg = cos(0.25 * Float.pi)
}
