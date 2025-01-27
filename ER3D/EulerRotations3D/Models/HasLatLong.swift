//
//  HasLatLong.swift
//  EulerRotations3D
//
//  Created by Eliott Radcliffe on 1/27/25.
//

import Foundation
import RealityKit

/// Extension of the `RotationSequence` class to indicate a sequence where the associated model also has options for displaying latitude and longitude
protocol HasLatLong: RotationSequence {
    var lat: EulerAngle { get set }
    var long: EulerAngle { get set }
}


extension HasLatLong {
    mutating func setLatLong(given hit: CollisionCastHit) {
        // Convert the hit position in the world to one that is local to the sphere
        let hitPositionLocal = hit.entity.convert(position: hit.position, from: nil)
        
        // Perform calculations for radius, latitude, and longitude
        let radius = length(hitPositionLocal)
        lat.radians = asin(hitPositionLocal.y / radius / 0.8)  // Strangely, angles were getting clamped at [-45, 45] deg, dividing through seems to help, but I don't have a good explanation
        long.radians = atan2(hitPositionLocal.z, -hitPositionLocal.x)
    }
    
    mutating func setLatLong(lat: Float, long: Float) {
        self.lat.radians = lat
        self.long.radians = long
    }
    
    mutating func resetLatLong() {
        setLatLong(lat: 0, long: 0)
    }
}
