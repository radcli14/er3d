//
//  ER3DRotations.swift
//  ER3D
//
//  Created by Eliott Radcliffe on 5/30/24.
//

import Foundation
import SceneKit

struct YawPitchRollSceneModel: ER3DSceneModel {
    var scene = SCNScene()
    var cameraNode = SCNNode()
    
    var frame1 = FrameNode(scale: 0.975, color: .systemBlue)
    var frame2 = FrameNode(scale: 0.95, color: .systemGreen)
    var frame3 = FrameNode(scale: 0.925, color: .systemRed)
    
    var earthNode: SCNNode?
    var earthInitialRotation: SCNVector4?
    
    init() {
        setupScene()
        setupCamera()
    }
    
    // MARK: - Angles
    
    var yaw: Float = 0.0 {
        didSet {
            frame1.rotation = SCNVector4(x: 0, y: 0, z: 1, w: yaw)
        }
    }
    
    var pitch: Float = 0.0 {
        didSet {
            frame2.rotation = SCNVector4(x: 0, y: 1, z: 0, w: pitch)
        }
    }
    
    var roll: Float = 0.0 {
        didSet {
            frame3.rotation = SCNVector4(x: 1, y: 0, z: 0, w: roll)
        }
    }
}
