//
//  ContentViewController.swift
//  ER3D
//
//  Created by Eliott Radcliffe on 9/29/22.
//

import Foundation
import SceneKit

/**
 Controls the content of the `SceneKit` 3D components
 */
class ER3DViewModel: ObservableObject {
    @Published private var model = ER3DSceneModel()

    var yaw: Float {
        get { model.frame1.rotation.w }
        set { model.frame1.rotation = SCNVector4(x: 0, y: 0, z: 1, w: newValue) }
    }
    
    var pitch: Float {
        get { model.frame2.rotation.w }
        set { model.frame2.rotation = SCNVector4(x: 0, y: 1, z: 0, w: newValue) }
    }
    
    var roll: Float {
        get { model.frame3.rotation.w }
        set { model.frame3.rotation = SCNVector4(x: 1, y: 0, z: 0, w: newValue) }
    }
    
    var scene: SCNScene {
        model.scene
    }
    
    var camera: SCNNode {
        model.cameraNode
    }
}
