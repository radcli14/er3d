//
//  FrameView.swift
//  ER3D
//
//  Created by Eliott Radcliffe on 9/29/22.
//

import Foundation
import SceneKit

/**
 Creates three arrows that point in the +X, +Y, and +Z direction
 */
class FrameNode: SCNNode {
 
    init(scale: Double = 1.0, color: UIColor? = nil) {
        // Initialize the SCNNode class
        super.init()
        
        // Create the +X axis, which is red, and does not require rotation
        let xArrow = ArrowNode(scale: scale, color: color ?? .systemRed)
        
        // Create the +Y axis, which is green, and has a 90 deg rotation about the +Z axis
        let yArrow = ArrowNode(scale: scale, color: color ?? .systemGreen)
        yArrow.rotate(
            by: SCNQuaternion(x: 0, y: 0, z: sin(Float.pi/4), w: cos(Float.pi/4)),
            aroundTarget: position
        )
        
        // Create the +Z axis, which is blue, and rotated by -90deg about the +Y axis
        let zArrow = ArrowNode(scale: scale, color: color ?? .systemBlue)
        zArrow.rotate(
            by: SCNQuaternion(x: 0, y: sin(Float.pi/4), z: 0, w: -cos(Float.pi/4)),
            aroundTarget: position
        )
        
        // Add the arrows to the base node
        addChildNode(xArrow)
        addChildNode(yArrow)
        addChildNode(zArrow)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
