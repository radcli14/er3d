//
//  Planets.swift
//  SwiftyTwoLinks
//
//  Created by Eliott Radcliffe on 5/27/22.
//

import Foundation
import SceneKit

/**
 Base struct for a planet, most importantly will provide a spherical geometry, and a SCNNode that can be added to the scene
 */
struct Planet {
    /// Radius of the planet
    var radius: Double {
        set {
            geometry.radius = newValue
        }
        get {
            return geometry.radius
        }
    }
    
    let geometry: SCNSphere!
    let node: SCNNode!
    
    init(radius: Double = 31.4,
         x: Double = 0.0, y: Double = 0.0, z: Double = 0.0,
         xAngle: Double = 0.0, yAngle: Double = 0.0, zAngle: Double = 0.0,
         image: String? = nil, specular: String? = nil, normal: String? = nil, displacement: String? = nil,
         isGeodesic: Bool = false, segmentCount: Int? = nil
    ) {
        // Create the spherical geometry, with optional image that gets wrapped around it, and shininess
        geometry = SCNSphere(radius: radius)
        geometry.isGeodesic = isGeodesic
        geometry.segmentCount = segmentCount ?? 128

        // Update the image textures
        if let image {
            geometry.materials.first?.diffuse.contents = UIImage(named: image)
        }
        if let specular {
            geometry.materials.first?.specular.contents = UIImage(named: specular)
        }
        if let normal {
            geometry.materials.first?.normal.contents = UIImage(named: normal)
        }
        if let displacement {
            geometry.materials.first?.displacement.contents = UIImage(named: displacement)
            geometry.materials.first?.displacement.intensity = 0.0
        }

        // Create the node that gets added to the scene
        node = SCNNode(geometry: geometry)
        node.position = SCNVector3(x, y, z)
        print(SCNQuaternion.forYawPitchRollSequenceInDegrees(yaw: Float(zAngle), pitch: Float(xAngle), roll: Float(xAngle)))
        node.orientation = SCNQuaternion.forYawPitchRollSequenceInDegrees(yaw: Float(zAngle), pitch: Float(xAngle), roll: Float(xAngle))
    }
}
