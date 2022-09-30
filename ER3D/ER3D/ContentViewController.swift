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
    
    init() {
        setupScene()
        setupCamera()
    }
    
    /**
     Creates the `SCNScene` object
     */
    func setupScene() {
        scene = SCNScene()
        let box = SCNBox()
        let boxNode = SCNNode(geometry: box)
        box.firstMaterial?.diffuse.contents = UIColor.systemBlue
        scene.rootNode.addChildNode(boxNode)
    }
    
    /**
     Creates a `SCNNode` with a `SCNCamera` attached
     */
    func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: -2.0, y: -2.0, z: 0.0)
        cameraNode.look(
            at: SCNVector3(0, 0, 0),
            up: SCNVector3(0, 0, 1),
            localFront: SCNVector3(0, 0, -1)
        )
        scene.rootNode.addChildNode(cameraNode)
    }
}
