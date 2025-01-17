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

    func rotateDevice(to newOrientation: UIDeviceOrientation) {
        isLandscape = newOrientation == .landscapeLeft || newOrientation == .landscapeRight
    }
    
    @Published var controlVisibility = ControlVisibility.angleControls
    
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
    
    var lat: Float {
        get { model.lat }
        set { model.lat = newValue }
    }
    
    var long: Float {
        get { model.long }
        set { model.long = newValue }
    }
    
    var cameraAngle: CGFloat {
        model.cameraAngle
    }
    
    // MARK: - Intents
    
    func resetYawPitchRollAngles() {
        yaw = 0
        pitch = 0
        roll = 0
    }
    
    func setLatLong(lat: Float, long: Float) {
        model.lat = lat
        model.long = long
    }
    
    func resetLatLong() {
        model.lat = 0
        model.long = 0
    }
}
