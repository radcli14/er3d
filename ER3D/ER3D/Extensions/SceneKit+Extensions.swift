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
    
    var asQuat: simd_quatd {
        return simd_quatd(ix: Double(x), iy: Double(y), iz: Double(z), r: Double(w))
    }
    
    // MARK: - Angle Presets
    
    static let fortyFiveDegAboutX = SCNQuaternion(x: .halfSinFortyFiveDeg, y: 0, z: 0, w: .halfCosFortyFiveDeg)
    static let ninetyDegAboutMinusX = SCNQuaternion(x: .halfSinNinetyDeg, y: 0, z: 0, w: -.halfCosNinetyDeg)
    static let ninetyDegAboutY = SCNQuaternion(x: 0, y: .halfSinNinetyDeg, z: 0, w: .halfCosNinetyDeg)
    static let ninetyDegAboutMinusY = SCNQuaternion(x: 0, y: .halfSinNinetyDeg, z: 0, w: -.halfCosNinetyDeg)
    static let ninetyDegAboutZ = SCNQuaternion(x: 0, y: 0, z: .halfSinNinetyDeg, w: .halfCosNinetyDeg)
    static let ninetyDegAboutMinusZ = SCNQuaternion(x: 0, y: 0, z: .halfSinNinetyDeg, w: -.halfCosNinetyDeg)
    
    // MARK: - Euler Angles
    
    static func forYawAngleInDegrees(_ angle: Float) -> SCNQuaternion {
        let halfAngle = 0.5 * Float.pi / 180.0 * angle
        return SCNQuaternion(x: 0, y: 0, z: sin(halfAngle), w: cos(halfAngle))
    }
    
    static func forPitchAngleInDegrees(_ angle: Float) -> SCNQuaternion {
        let halfAngle = 0.5 * Float.pi / 180.0 * angle
        return SCNQuaternion(x: 0, y: sin(halfAngle), z: 0, w: cos(halfAngle))
    }
    
    static func forRollAngleInDegrees(_ angle: Float) -> SCNQuaternion {
        let halfAngle = 0.5 * Float.pi / 180.0 * angle
        return SCNQuaternion(x: sin(halfAngle), y: 0, z: 0, w: cos(halfAngle))
    }
    
    static func forYawPitchRollSequenceInDegrees(yaw: Float, pitch: Float, roll: Float) -> SCNQuaternion {
        let rollQuat = self.forRollAngleInDegrees(roll).asQuat
        let pitchQuat = self.forPitchAngleInDegrees(pitch).asQuat
        let yawQuat = self.forYawAngleInDegrees(yaw).asQuat
        print("rollQuat = \(rollQuat)")
        let quat = rollQuat * pitchQuat * yawQuat
        print("quat = \(quat)")
        return SCNQuaternion(x: Float(quat.axis.x), y: Float(quat.axis.y), z: Float(quat.axis.z), w: Float(quat.angle))
    }
}

extension Float {
    static let halfSinFortyFiveDeg = sin(0.125 * Float.pi)
    static let halfCosFortyFiveDeg = cos(0.125 * Float.pi)
    static let halfSinNinetyDeg = sin(0.25 * Float.pi)
    static let halfCosNinetyDeg = cos(0.25 * Float.pi)
}
