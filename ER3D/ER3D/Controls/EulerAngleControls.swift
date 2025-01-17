//
//  EulerAngleControls.swift
//  ER3D
//
//  Created by Eliott Radcliffe on 1/13/25.
//

import SwiftUI

/// The stack of three sliders representing the yaw, pitch, and roll angles
struct EulerAngleControls: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    @Binding var yaw: Float
    @Binding var pitch: Float
    @Binding var roll: Float
    let onResetAction: () -> Void
    
    var body: some View {
        if verticalSizeClass == .compact {
            HStack {
                eulerAngleControlsInStack
            }
            .padding(.bottom, Constants.sliderPadding)
        } else {
            VStack(spacing: Constants.sliderSpacing) {
                eulerAngleControlsInStack
            }
            .padding(Constants.sliderPadding)
        }
    }
    
    @ViewBuilder
    private var eulerAngleControlsInStack: some View {
        Text("Yaw → Pitch → Roll Sequence").font(.headline)
            .angleSliderContextMenu("Yaw → Pitch → Roll", onResetAction: onResetAction)
        AngleSlider(angle: $yaw, name: "Yaw", symbol: "ψ")
        AngleSlider(angle: $pitch, name: "Pitch", symbol: "𝜃")
        AngleSlider(angle: $roll, name: "Roll", symbol: "φ")
    }
    
    /// Dimension of the sheet that pops up from the bottom
    private var angleControlsHeight: CGFloat {
        isLandscape ? 64 : 212
    }
    
    var isLandscape: Bool {
        verticalSizeClass == .compact
    }
    
    private struct Constants {
        static let sliderPadding = CGFloat(12)
        static let sliderSpacing = CGFloat(0)
    }
}

#Preview {
    @Previewable @State var yaw: Float = 0.0
    @Previewable @State var pitch: Float = 0.0
    @Previewable @State var roll: Float = 0.0
    EulerAngleControls(yaw: $yaw, pitch: $pitch, roll: $roll) {
        print("Reset")
    }
}
