//
//  VariableDescriptions.swift
//  ER3D
//
//  Created by Eliott Radcliffe on 6/11/24.
//

import Foundation

let variableDescriptions: [String: String] = [
    "Yaw → Pitch → Roll": "The Yaw → Pitch → Roll Euler angle sequence is common in aerospace applications, and is often referred to as a 3-2-1 sequence based on the order the three angles are applied. In our example, we depict orientation of a ship relative to a local geodetic horizon plane with a X=North, Y=East, Z=Down (or, NED) convention.",
    "Yaw": "The yaw angle (ψ) is a rotation about the Z-axis of the base frame. If we use a NED convention, then we may think of yaw as a compass angle:\n  - ψ = 0deg → facing north\n  - ψ = 45deg → facing northeast\n  - ψ = 90deg → facing east\n  ... etc",
    "Pitch": "The pitch angle (𝜃) is a rotation about the y′-axis of the first rotated frame, after yaw rotation. If we use a NED convention, then we may think of pitch as the slope:\n  - 𝜃 = 0deg → level\n  - 𝜃 = 45deg → facing uphill\n  - 𝜃 = -45deg → facing downhill\n  ... etc",
    "Roll": "The roll angle (φ) is a rotation about the x″-axis of the second rotated frame, after yaw and pitch rotation. If we use a NED convention, then we may think of roll as a banking maneuver to turn:\n  - φ = 0deg → straight\n  - φ = 45deg → banked right\n  - φ = -45deg → banked left\n  ... etc",
    
    "Procession → Nutation → Spin": "The Procession → Nutation → Spin sequence is commonly used for spinning tops, gyroscopes, or satellites, and is often referred to as a 3-1-3 sequence based on the order the three angles are defined. In our example, we depict orientation of a gyroscope that can be tilted and spun about the respective axes.",
    "Procession": "The procession angle (φ) is a rotation about the Z-axis of the base frame. For a spinning top, this is the axis pointing upward, similarly for a satellite, the axis pointing radially from the center of the earth.",
    "Nutation": "The nutation angle (𝜃) is a rotation about the x′-axis of the first rotated frame, after procession. This is an axis that runs parallel to the ground, or surface of the Earth, and defines a tilt relative to the vertical axis.",
    "Spin": "The spin angle (ψ) is a rotation about the z″-axis of the second rotated frame, after procession and rotation. This defines the rotation of the gyro or top about its own central axis after transformation into its own body-fixed frame.",
    
    "Latitude & Longitude": "Latitude and longitude angles in degrees are commonly used to define a location on the surface of the earth. Latitude defines a location in north-south coordinates, and longitude in east-west coordinates.",
    "Latitude": "Lines of constant latitude run parallel to the Earth's equator, with zero latitude being on the equator itself. Increasing latitude above zero indicates more northerly locations, while negative is more southerly. Maximum and minimum latitude at the poles are 90 and -90 degrees.",
    "Longitude": "Lines of constant longitude run from the north to the south pole. Zero longitude is known as the Prime Meridian, and crosses through Greenwich, England, sections of France, Spain, and Western Africa. Increasing longitude indicates moving east, while decreasing indicates moving west."
]
