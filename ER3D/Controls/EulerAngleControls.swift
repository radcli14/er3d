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
    
    @State private var showInfo = false
    
    var body: some View {
        VStack(spacing: 0) {
            headerLine
            eulerAngleControlsInStack
        }
        .padding(Constants.sliderPadding)
    }
    
    private var headerLine: some View {
        HStack {
            Button {
                onResetAction()
            } label: {
                Image(systemName: "arrow.counterclockwise.circle.fill")
            }
            Text("Yaw → Pitch → Roll Sequence").font(.headline)
                .popover(isPresented: $showInfo) {
                    PopoverContent(key: "Yaw → Pitch → Roll")
                }
            Button {
                showInfo = true
            } label: {
                Image(systemName: "info.circle.fill")
            }
        }
    }
    
    @ViewBuilder
    private var eulerAngleControlsInStack: some View {
        if isLandscape {
            HStack(spacing: sliderSpacing) {
                eulerAngleControlsList
            }
        } else {
            VStack(spacing: sliderSpacing) {
                eulerAngleControlsList
            }
            .padding(.top)
        }
    }
    
    @ViewBuilder
    private var eulerAngleControlsList: some View {
        AngleSlider(angle: $yaw, name: "Yaw", symbol: "ψ")
        AngleSlider(angle: $pitch, name: "Pitch", symbol: "𝜃")
        AngleSlider(angle: $roll, name: "Roll", symbol: "φ")
    }

    private var sliderSpacing: CGFloat {
        isLandscape ? 36 : 12
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
