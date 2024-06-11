//
//  View+Extensions.swift
//  ER3D
//
//  Created by Eliott Radcliffe on 5/31/24.
//

import SwiftUI

// Our custom view modifier to track rotation and
// call our action
struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

/**
 A `ViewModifier` to generate a context menu to either show info about or reset a given angle
 - Parameters:
   - key: The name of the angle assigned to this slider
   - onReset: Function that is called when you tap the reset button to set the angle to zero
 */
private struct AngleSliderContextMenu: ViewModifier {
    let key: String
    let onResetAction: () -> Void
    let info: String
    @State private var showInfo = false

    init(_ key: String, _ onReset: @escaping () -> Void) {
        self.key = key
        info = variableDescriptions[key] ?? key
        onResetAction = onReset
    }
    
    func body(content: Content) -> some View {
        content.contextMenu {
            Text(key)
            Button(action: { showInfo.toggle() }) {
                Text("Show Info")
            }
            Button(role: .destructive, action: { onResetAction() }) {
                Text("Reset to Zero")
            }
        }
        .popover(isPresented: $showInfo, content: { Text(info) })
    }
}

/// A View wrapper to make the modifiers easier to use
extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
    
    func angleSliderContextMenu(_ key: String, onResetAction: @escaping () -> Void) -> some View {
        modifier(AngleSliderContextMenu(key, onResetAction))
    }
}
