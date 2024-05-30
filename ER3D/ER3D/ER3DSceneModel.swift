//
//  ER3DRotations.swift
//  ER3D
//
//  Created by Eliott Radcliffe on 5/30/24.
//

import Foundation
import SceneKit

struct ER3DSceneModel {
    var scene: SCNScene!
    var cameraNode: SCNNode!
    
    let frame1 = FrameNode(scale: 0.975, color: .systemBlue)
    let frame2 = FrameNode(scale: 0.95, color: .systemGreen)
    let frame3 = FrameNode(scale: 0.925, color: .systemRed)
    
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
    
    // MARK: - Setup
    
    /**
     Creates the `SCNScene` object
     */
    private mutating func setupScene() {
        // Initiate the basic scene
        scene = SCNScene()
        
        // Add the ship to the scene
        let shipScene = SCNScene(named: "art.scnassets/ship.scn")!
        let ship = shipScene.rootNode

        // Move the ship forward so that it is centered at the origin
        ship.localTranslate(by: SCNVector3(0, 0, 0.6))
        
        // Rotate so the nose points to the +X
        ship.rotate(
            by: SCNQuaternion(x: 0, y: sin(0.25*Float.pi), z: 0, w: cos(0.25*Float.pi)),
            aroundTarget: SCNVector3(0, 0, 0)
        )
        
        // Rotate so the Z axis is down
        ship.rotate(
            by: SCNQuaternion(x: -sin(0.25*Float.pi), y: 0, z: 0, w: cos(0.25*Float.pi)),
            aroundTarget: SCNVector3(0, 0, 0)
        )
        
        // Add the frames to the scene
        let frame0 = FrameNode(scale: 1.0, color: .black)
        scene.rootNode.addChildNode(frame0)
        frame0.addChildNode(frame1)
        frame1.addChildNode(frame2)
        frame2.addChildNode(frame3)
        frame3.addChildNode(ship)
    }
    
    /**
     Creates a `SCNNode` with a `SCNCamera` attached
     */
    private mutating func setupCamera() {
        // Initialize the camera and add it to the scene
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // Position should be set prior to lookAt, otherwise you will look at the target,
        // then get moved away from its intended vector
        cameraNode.position = SCNVector3(x: -2.0, y: 2.0, z: -2.0)
        cameraNode.look(
            at: SCNVector3(0, 0, 0),
            up: SCNVector3(0, 0, -1),
            localFront: SCNVector3(0, 0, -1)
        )
    }
}

