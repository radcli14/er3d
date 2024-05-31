//
//  ER3DSceneModel.swift
//  ER3D
//
//  Created by Eliott Radcliffe on 5/31/24.
//

import Foundation
import SceneKit

protocol ER3DSceneModel {
    var scene: SCNScene { get set }
    var cameraNode: SCNNode { get set }
    var frame1: FrameNode { get set }
    var frame2: FrameNode { get set }
    var frame3: FrameNode { get set }
}

extension ER3DSceneModel {
    // MARK: - Setup
    
    /// Creates the `SCNScene` object containing the frames and ship
    mutating func setupScene(for assetName: String = "art.scnassets/ship.scn") {
        // Create the background skybox
        scene.background.contents = backgroundImages
        
        // Define an Earth in the background
        let earthRadius = 10.0
        let earth = Planet(
            radius: earthRadius,
            x: 0,
            y: 0,
            z: 1.0 + earthRadius,
            xAngle: 4.0,
            yAngle: 0.0,
            image: "8081_earthmap10k",
            specular: "8081_earthspec10k"
        )
        scene.rootNode.addChildNode(earth.node)
        
        // Add the ship to the scene
        let ship = getShip(named: assetName)

        // Add the frames to the scene
        let frame0 = FrameNode(scale: 1.0, color: .systemGray)
        scene.rootNode.addChildNode(frame0)
        frame0.addChildNode(frame1)
        frame1.addChildNode(frame2)
        frame2.addChildNode(frame3)
        frame3.addChildNode(ship)
    }
    
    /// Creates a `SCNNode` with a `SCNCamera` attached
    mutating func setupCamera() {
        // Initialize the camera and add it to the scene
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // Position should be set prior to lookAt, otherwise you will look at the target,
        // then get moved away from its intended vector
        cameraNode.position = SCNVector3(x: -2.0, y: 2.0, z: -2.0)
        cameraNode.look(
            at: .zero,
            up: SCNVector3(0, 0, -1),
            localFront: SCNVector3(0, 0, -1)
        )
    }
    
    // MARK: - Objects and Images
    
    /// Get the `SCNNode` from the ship scene with specified file name, and translates and rotates it to intended position
    func getShip(named assetName: String = "art.scnassets/ship.scn") -> SCNNode {
        let shipScene = SCNScene(named: assetName)!
        let ship = shipScene.rootNode

        // Move the ship forward so that it is centered at the origin
        ship.localTranslate(by: SCNVector3(0, 0, 0.6))
        
        // Rotate so the nose points to the +X and the Z axis is down
        ship.rotate(by: .ninetyDegAboutY, aroundTarget: .zero)
        ship.rotate(by: .ninetyDegAboutMinusX, aroundTarget: .zero)
        return ship
    }
    
    var backgroundImages: [UIImage] {
        let images = ["px", "nx", "py", "ny", "pz", "nz"]
        return images.map { UIImage(named: $0) ?? UIImage() }
    }
}
