//
//  Tips.swift
//  EulerRotations3D
//
//  Created by Eliott Radcliffe on 1/31/25.
//

import Foundation
import TipKit

/// Tips that are shown inside the `EulerAngleControls` or `LatLongAngleIndicators`
enum AngleTips: String, Tip {
    case reset
    case info
    
    var id: String {
        rawValue
    }
    
    var title: Text {
        switch self {
        case .reset: Text("Reset Angles")
        case .info: Text("Info Button")
        }
    }
    
    var message: Text? {
        switch self {
        case .reset: Text("Tap to reset all of the angles to zero")
        case .info: Text("Tap to view information about this property")
        }
    }
    
    var image: Image? {
        switch self {
        case .reset: Image(systemName: "arrow.counterclockwise")
        case .info: Image(systemName: "info.bubble")
        }
    }
}

/// Tips that are shown inside the `BottomButtons`
enum ControlTips: String, Tip {
    case bottomButtons
    case eulerAngles
    case latLong
    case settings
    case reset
    case translation
    case rotation
    case scale
    
    var id: String {
        rawValue
    }
    
    var title: Text {
        switch self {
        case .bottomButtons: Text("Bottom Buttons")
        case .eulerAngles: Text("Euler Angles")
        case .latLong: Text("Latitude and Longitude")
        case .settings: Text("Settings")
        case .reset: Text("Reset")
        case .translation: Text("Translation Gesture")
        case .rotation: Text("Rotation Gesture")
        case .scale: Text("Scale Gesture")
        // default: Text("Error")
        }
    }
    
    var message: Text? {
        switch self {
        case .bottomButtons: Text("Use the bottom row of buttons to edit angles and other states of the model")
        case .eulerAngles: Text("Tap to open the control sliders")
        case .latLong: Text("Tap to enable repositioning")
        case .settings: Text("Tap to toggle between standard and AR views, or change the model")
        case .reset: Text("Tap to reposition the model to a default location")
        case .translation: Text("Tap on the model with one finger to move the model")
        case .rotation: Text("Drag with two fingers to rotate the model")
        case .scale: Text("Pinch with two fingers to scale the model")
        // default: Text("Tried to show a tip that doesn't exist")
        }
    }
    
    var image: Image? {
        switch self {
        case .bottomButtons: Image(systemName: "slider.horizontal.3")
        case .eulerAngles: Image(systemName: "rotate.3d.circle")
        case .latLong: Image(systemName: "globe")
        case .settings: Image(systemName: "gear")
        case .reset: Image(systemName: "arrow.counterclockwise")
        case .translation: Image(systemName: "hand.tap")
        case .rotation: Image(systemName: "hand.point.up")
        case .scale: Image(systemName: "hand.pinch")
        // default: Image(systemName: "question.mark")
        }
    }
}
