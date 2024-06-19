//
//  ArrowView.swift
//  ER3D
//
//  Created by Eliott Radcliffe on 9/29/22.
//

import Foundation
import SceneKit

/**
 Creates an arrow that points in the +Y direction, with length equal to the provided scale.
 */
class ArrowNode: SCNNode {

    // Geometry constants
    private let tailHeightScale = 0.8
    private let tailWidthScale = 0.075
    private let headHeightScale = 0.2
    private let headWidthScale = 0.15
    
    init(
        scale: Double = 1.0,
        color: UIColor = .systemGray
    ) {
        // Initialize the SCNNode class
        super.init()
        
        // Create the geoemetry for the tail of the arrow, and set its color
        let tailGeometry = SCNPyramid(
                width: tailWidthScale*scale,
                height: tailHeightScale*scale,
                length: tailWidthScale*scale
        )
        tailGeometry.materials.first?.diffuse.contents = color
        
        // Create the node at which we attach the tail geometry
        let tailNode = SCNNode(geometry: tailGeometry)


        // Rotate by 90 deg so that the flat points to the +X direction
        tailNode.rotate(
            by: SCNQuaternion(x: 0, y: 0, z: sin(Float.pi/4), w: cos(Float.pi/4)),
            aroundTarget: position
        )
        
        // Rotate by 45 deg
        tailNode.rotate(
            by: SCNQuaternion(x: sin(Float.pi/8), y: 0, z: 0, w: cos(Float.pi/8)),
            aroundTarget: position
        )
        
        // Shift the origin in the +X direction
        tailNode.position.x = Float(tailHeightScale*scale)
        
        // Create the geoemetry for the head of the arrow, and set its color
        let headGeometry = SCNPyramid(
                width: headWidthScale*scale,
                height: headHeightScale*scale,
                length: headWidthScale*scale
        )
        headGeometry.materials.first?.diffuse.contents = color
        
        // Create the node at which we attach the head geometry
        let headNode = SCNNode(geometry: headGeometry)

        // Rotate by -90 deg so that the arrow points to the +X direction
        headNode.rotate(
            by: SCNQuaternion(x: 0, y: 0, z: sin(Float.pi/4), w: -cos(Float.pi/4)),
            aroundTarget: position
        )
        
        // Rotate by 45 deg
        headNode.rotate(
            by: SCNQuaternion(x: sin(Float.pi/8), y: 0, z: 0, w: cos(Float.pi/8)),
            aroundTarget: position
        )
        
        // Shift the origin upwards
        headNode.position.x = Float(tailHeightScale*scale)
        
        // Add the nodes to the root node
        addChildNode(tailNode)
        addChildNode(headNode)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

