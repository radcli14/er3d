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
    // Radius of the planet
    var radius: Double {
        set {
            geometry.radius = newValue
        }
        get {
            return geometry.radius
        }
    }
    
    // Orientation of the planet
    private var _xAngle = 0.0
    var xAngle: Double {
        set {
            _xAngle = newValue
            updateOrientation()
        }
        get {
            return _xAngle
        }
    }
    
    private var xQuat: simd_quatd {
        get {
            return simd_quatd(ix: sin(0.5 * xAngle), iy: 0, iz: 0, r: cos(0.5 * xAngle))
        }
    }
    
    private var _yAngle = 0.0
    var yAngle: Double {
        set {
            _yAngle = newValue
            updateOrientation()
        }
        get {
            return _yAngle
        }
    }
    
    private var yQuat: simd_quatd {
        get {
            return simd_quatd(ix: 0, iy: sin(0.5 * yAngle), iz: 0, r: cos(0.5 * yAngle))
        }
    }
    
    private var quat: simd_quatd {
        get {
            return yQuat * xQuat
        }
    }
    
    // Image that gets super-imposed on the planet, argument provides as a string file name
    private var _image: UIImage? = nil
    private var _specular: UIImage? = nil
    
    var isGeodesic = false
    var segmentCount: Int? = nil
    var shininess: Double? = nil
    
    let geometry: SCNSphere!
    let node: SCNNode!
    
    init(radius: Double = 31.4,
         x: Double = 0.0, y: Double = 0.0, z: Double = 0.0,
         xAngle: Double = 0.0, yAngle: Double = 0.0,
         image: String? = nil, specular: String? = nil,
         isGeodesic: Bool = false, segmentCount: Int? = nil, shininess: Double? = nil
    ) {
        // Unpack the arguments
        _xAngle = xAngle
        _yAngle = yAngle
        if image != nil {
            _image = UIImage(named: image!)
        }
        if specular != nil {
            _specular = UIImage(named: specular!)
        }
        
        // Create the spherical geometry, with optional image that gets wrapped around it, and shininess
        geometry = SCNSphere(radius: radius)
        geometry.isGeodesic = isGeodesic
        geometry.segmentCount = segmentCount ?? 128
        geometry.materials.first?.diffuse.contents = _image
        geometry.materials.first?.specular.contents = _specular
        geometry.materials.first?.shininess = shininess ?? 0.0
        
        // Create the node that gets added to the scene
        node = SCNNode(geometry: geometry)
        node.position = SCNVector3(x, y, z)
        updateOrientation()
    }
    
    func updateOrientation() {
        node.orientation = SCNQuaternion(quat.vector)
    }
}
