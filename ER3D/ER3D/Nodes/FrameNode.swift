//
//  FrameView.swift
//  ER3D
//
//  Created by Eliott Radcliffe on 9/29/22.
//

import Foundation
import SceneKit

/**
 Creates three arrows that point in the _+X_, _+Y_, and _+Z_ direction
 - Parameters:
   - scale: the scale factor to be applied in all three axes to the geometry
   - color: the color of the arrow
 */
class FrameNode: SCNNode {
    var totalScale = 1.0
    var color: UIColor?
 
    init(scale: Double = 1.0, color: UIColor? = nil) {
        // Initialize the `SCNNode` class
        super.init()
        
        // Store the initialization arguments, accessed by the computed vars
        totalScale = scale
        self.color = color
        
        // Add the arrows to the base node
        addChildNode(xArrow)
        addChildNode(yArrow)
        addChildNode(zArrow)
    }
    
    // MARK: - Arrows
    
    /// The _+X_ axis, which is red (or user specified color), and does not require rotation
    var xArrow: ArrowNode {
        ArrowNode(scale: totalScale, color: color ?? .systemRed)
    }
    
    /// The _+Y_ axis, which is green (or user specified color), and has a 90 deg rotation about the _+Z_ axis
    var yArrow: ArrowNode {
        let yArrow = ArrowNode(scale: totalScale, color: color ?? .systemGreen)
        yArrow.rotate(by: .ninetyDegAboutZ, aroundTarget: position)
        return yArrow
    }
    
    /// The _+Z_ axis, which is blue (or user specified color), and rotated by -90deg about the _+Y_ axis
    var zArrow: ArrowNode {
        let zArrow = ArrowNode(scale: totalScale, color: color ?? .systemBlue)
        zArrow.rotate(by: .ninetyDegAboutMinusY, aroundTarget: position)
        return zArrow
    }
    
    // MARK: - Protocol Requirements
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
