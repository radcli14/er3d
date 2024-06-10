//
//  ArrowNode.swift
//  ER3D
//
//  Created by Eliott Radcliffe on 9/29/22.
//

import Foundation
import SceneKit

/**
 Creates an arrow that points in the +_X_ direction, with length equal to the provided scale, and specified color.
 - Parameters:
   - scale: the scale factor to be applied in all three axes to the geometry
   - color: the color of the arrow
 */
class ArrowNode: SCNNode {
    var totalScale = 1.0
    var color = UIColor.systemGray
    
    init(
        scale: Double = 1.0,
        color: UIColor = .systemGray
    ) {
        // Initialize the SCNNode class
        super.init()
        
        // Store the initialization arguments, accessed by the computed vars
        totalScale = scale
        self.color = color

        // Add the nodes to the root node
        addChildNode(tailNode)
        addChildNode(headNode)
    }
    
    // MARK: - Subsidiary Geometries
    
    /// Create the geoemetry for the tail of the arrow, and set its color/
    private var tailGeometry: SCNGeometry {
        let tailGeometry = SCNCone(
            topRadius: 0,
            bottomRadius: Constants.tailWidthScale * totalScale,
            height: Constants.tailHeightScale
        )
        tailGeometry.materials.first?.diffuse.contents = color
        tailGeometry.materials.first?.emission.contents = color
        tailGeometry.materials.first?.emission.intensity = Constants.emissionIntensity
        
        return tailGeometry
    }
    
    /// Create the geoemetry for the head of the arrow, and set its color
    private var headGeometry: SCNGeometry {
        let headGeometry = SCNCone(
            topRadius: 0,
            bottomRadius: Constants.headWidthScale * totalScale,
            height: Constants.headHeightScale
        )
        headGeometry.materials.first?.diffuse.contents = color
        headGeometry.materials.first?.emission.contents = color
        headGeometry.materials.first?.emission.intensity = Constants.emissionIntensity
        return headGeometry
    }
    
    // MARK: - Subsidiary Nodes
    
    /// Create the node at which we attach the tail geometry
    private var tailNode: SCNNode {
        let tailNode = SCNNode(geometry: tailGeometry)

        // Rotate so that the flat points to the +X direction, and shift the origin
        tailNode.rotate(by: .ninetyDegAboutZ, aroundTarget: position)
        tailNode.position.x = Float(0.5 * Constants.tailHeightScale)
        
        return tailNode
    }
    
    /// Create the node at which we attach the head geometry/
    private var headNode: SCNNode {
        let headNode = SCNNode(geometry: headGeometry)

        // Rotate so that the arrow points to the +X direction, and shift the origin to mate with the tail
        headNode.rotate(by: .ninetyDegAboutMinusZ, aroundTarget: position)
        headNode.position.x = Float(Constants.tailHeightScale + 0.5 * Constants.headHeightScale)
        
        return headNode
    }
    
    // MARK: - Constants
    
    private struct Constants {
        static let tailHeightScale = 0.8
        static let tailWidthScale = 0.02
        static let headHeightScale = 0.2
        static let headWidthScale = 0.03
        static let emissionIntensity = CGFloat(0.5)
    }
    
    // MARK: - Protocol Requirements
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

