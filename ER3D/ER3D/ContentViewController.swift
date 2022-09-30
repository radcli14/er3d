//
//  ContentViewController.swift
//  ER3D
//
//  Created by Eliott Radcliffe on 9/29/22.
//

import Foundation
import SceneKit

class ContentViewController {
    var scene: SCNScene!
    var cameraNode: SCNNode!
    var yaw: Float = 0
    var pitch: Float = 0
    var roll: Float = 0
    let frame1 = FrameNode(scale: 0.9)
    let frame2 = FrameNode(scale: 0.8)
    let frame3 = FrameNode(scale: 0.7)
    
    init() {
        setupScene()
        setupCamera()
    }
    
    /**
     Creates the `SCNScene` object
     */
    func setupScene() {
        // Initiate the basic scene
        scene = SCNScene()
        
        // Add the ship to the scene
        let shipScene = SCNScene(named: "art.scnassets/ship.scn")!
        let shipNode = shipScene.rootNode
        scene.rootNode.addChildNode(shipNode)
        
        // Move the ship forward so that it is centered at the origin
        shipNode.localTranslate(by: SCNVector3(0, 0, 0.6))
        
        // Rotate so the nose points to the +X
        shipNode.rotate(
            by: SCNQuaternion(x: 0, y: sin(0.25*Float.pi), z: 0, w: cos(0.25*Float.pi)),
            aroundTarget: SCNVector3(0, 0, 0)
        )
        
        // Rotate so the Z axis is down
        shipNode.rotate(
            by: SCNQuaternion(x: -sin(0.25*Float.pi), y: 0, z: 0, w: cos(0.25*Float.pi)),
            aroundTarget: SCNVector3(0, 0, 0)
        )
        
        // Add the frames to the scene
        let frame0 = FrameNode(scale: 1.0)
        scene.rootNode.addChildNode(frame0)
        frame0.addChildNode(frame1)
        frame1.addChildNode(frame2)
        frame2.addChildNode(frame3)
        
        update(yaw: 0.5, pitch: 0.5, roll: 0.5)
    }
    
    /**
     Creates a `SCNNode` with a `SCNCamera` attached
     */
    func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: -2.0, y: 2.0, z: -2.0)
        cameraNode.look(
            at: SCNVector3(0, 0, 0),
            up: SCNVector3(0, 0, -1),
            localFront: SCNVector3(0, 0, -1)
        )
        scene.rootNode.addChildNode(cameraNode)
    }
    
    /**
     Updates the orientation of the ship and intermediate frames based on Euler angles
     */
    func update(yaw: Float, pitch: Float, roll: Float) {
        frame1.localRotate(by: SCNQuaternion(x: 0, y: 0, z: sin(0.5*yaw), w: cos(0.5*yaw)))
        frame2.localRotate(by: SCNQuaternion(x: 0, y: sin(0.5*pitch), z: 0, w: cos(0.5*pitch)))
        frame3.localRotate(by: SCNQuaternion(x: sin(0.5*roll), y: 0, z: 0, w: cos(0.5*roll)))
    }
}
