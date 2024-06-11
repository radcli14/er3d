//
//  VariableDescriptions.swift
//  ER3D
//
//  Created by Eliott Radcliffe on 6/11/24.
//

import Foundation

let variableDescriptions: [String: String] = [
    "Yaw": "The yaw angle (ψ) is a rotation about the Z-axis of the base frame. If we use a X=North, Y=East, Z=Down (or, NED) convention, then we may think of yaw as a compass angle:\n  - ψ = 0deg → facing north\n  - ψ = 45deg → facing northeast\n  - ψ = 90deg → facing east\n  ... etc",
    "Pitch": "The pitch angle (𝜃) is a rotation about the y′-axis of the first rotated frame, after yaw rotation. If we use a NED convention, then we may think of pitch as the slope:\n  - 𝜃 = 0deg → level\n  - 𝜃 = 45deg → facing uphill\n  - 𝜃 = -45deg → facing downhill\n  ... etc",
    "Roll": "The roll angle (φ) is a rotation about the x″-axis of the second rotated frame, after yaw and pitch rotation. If we use a NED convention, then we may think of roll as a banking maneuver to turn:\n  - φ = 0deg → straight\n  - φ = 45deg → banked right\n  - φ = -45deg → banked left\n  ... etc"
]
