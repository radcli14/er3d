//
//  Tips.swift
//  EulerRotations3D
//
//  Created by Eliott Radcliffe on 1/31/25.
//

import Foundation
import TipKit

struct EulerAngleControlsTip: Tip {
    var title: Text {
        Text("Euler Angles")
    }
    
    var message: Text? {
        Text("Tap to open the control sliders")
    }
    
    var image: Image? {
        Image(systemName: "rotate.3d.circle")
    }
}

struct LatLongControlsTip: Tip {
    var title: Text {
        Text("Latitude and Longitude")
    }
    
    var message: Text? {
        Text("Tap to enable repositioning")
    }
    
    var image: Image? {
        Image(systemName: "globe")
    }
}

struct SettingsTip: Tip {
    var title: Text {
        Text("Settings")
    }
    
    var message: Text? {
        Text("Tap to toggle between standard and AR views, or change the model")
    }
    
    var image: Image? {
        Image(systemName: "gear")
    }
}

struct ResetTip: Tip {
    var title: Text {
        Text("Reset")
    }
    
    var message: Text? {
        Text("Tap to reposition the model to a default location")
    }
    
    var image: Image? {
        Image(systemName: "arrow.counterclockwise")
    }
}

struct ResetAnglesTip: Tip {
    var title: Text {
        Text("Reset Angles")
    }
    
    var message: Text? {
        Text("Tap to reset all of the angles to zero")
    }
    
    var image: Image? {
        Image(systemName: "arrow.counterclockwise")
    }
}

struct InfoButtonTip: Tip {
    var title: Text {
        Text("Info Button")
    }
    
    var message: Text? {
        Text("Tap to view information about this property")
    }
    
    var image: Image? {
        Image(systemName: "info.bubble")
    }
}

struct TranslationGestureTip: Tip {
    var title: Text {
        Text("Translation Gesture")
    }
    
    var message: Text? {
        Text("Tap on the model with one finger to move the model")
    }
    
    var image: Image? {
        Image(systemName: "hand.tap")
    }
}

struct RotationGestureTip: Tip {
    var title: Text {
        Text("Rotation Gesture")
    }
    
    var message: Text? {
        Text("Drag with two fingers to rotate the model")
    }
    
    var image: Image? {
        Image(systemName: "hand.point.up")
    }
}

struct ScaleGestureTip: Tip {
    var title: Text {
        Text("Scale Gesture")
    }
    
    var message: Text? {
        Text("Pinch with two fingers to scale the model")
    }
    
    var image: Image? {
        Image(systemName: "hand.pinch")
    }
}
