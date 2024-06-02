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

        // Add the ship and Earth to the scene
        let ship = getShip(named: assetName)
        if let earth = getEarth(lat: 42.7325, long: 84.555) {
            scene.rootNode.addChildNode(earth)
        }
        
        // Light is provided through sparks of energy of the mind that travel in rhyme form
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.light!.zFar = 100000.0
        lightNode.light!.intensity = 1000
        lightNode.position = SCNVector3(x: -360.0, y: 360.0, z: -1080.0)
        lightNode.light?.castsShadow = true
        scene.rootNode.addChildNode(lightNode)
        
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
    
    /// Get the `SCNNode` from the Earth .scn file
    func getEarth(named assetName: String = "art.scnassets/earth.scn", lat: Float = 0.0, long: Float = 0.0) -> SCNNode? {
        let earthScene = SCNScene(named: assetName)
        let earthNode = earthScene?.rootNode
        if let earthNode {
            earthNode.rotate(
                by: SCNQuaternion.forRollAngleInDegrees(long),
                aroundTarget: earthNode.childNodes.last?.position ?? .zero
            )
            earthNode.rotate(
                by: SCNQuaternion.forPitchAngleInDegrees(lat),
                aroundTarget: earthNode.childNodes.last?.position ?? .zero
            )
        }
        return earthNode
    }
    
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
