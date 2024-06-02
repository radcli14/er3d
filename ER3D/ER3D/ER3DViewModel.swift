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
    @Published private var model = YawPitchRollSceneModel()
    
    // MARK: - State Variables
    
    @Published var isLandscape = false
    @Published var angleControlsVisible = true
    @Published var latLongControlsVisible = false
    
    func rotateDevice(to newOrientation: UIDeviceOrientation) {
        isLandscape = newOrientation == .landscapeLeft || newOrientation == .landscapeRight
    }
    
    // MARK: - Scene
    
    var scene: SCNScene {
        model.scene
    }
    
    var camera: SCNNode {
        model.cameraNode
    }
    
    // MARK: - Angles
    
    var yaw: Float {
        get { model.yaw }
        set { model.yaw = newValue }
    }
    
    var pitch: Float {
        get { model.pitch }
        set { model.pitch = newValue }
    }
    
    var roll: Float {
        get { model.roll }
        set { model.roll = newValue }
    }
}
