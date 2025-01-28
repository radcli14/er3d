//
//  AngleSlider.swift
//  ER3D
//
//  Created by Eliott Radcliffe on 1/13/25.
//

import SwiftUI

/// A custom slider using specified angle limits, steps, and labels
struct AngleSlider: View {
    @Binding var angle: EulerAngle
    
    var body: some View {
        VStack(spacing: Constants.sliderSpacing) {
            Slider(
                value: $angle.radians,
                in: angle.range,
                step: Constants.sliderStep,
                label: { Text(angle.name) }
            )
            HStack {
                Button {
                    angle.radians = 0
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                }
                Text("\(angle.name) \(angle.symbol) = \(String(format: "%.0f", angle.degrees)) deg")
                    .font(.callout)
                    .foregroundColor(.secondary)
                Spacer()
                InfoButtonWithPopover(key: angle.name)
            }
        }
    }
    
    private struct Constants {
        static let sliderStep: Float = .pi / 180
        static let sliderSpacing: CGFloat = 0
    }
}

#Preview {
    @Previewable @State var angle: EulerAngle = .yaw
    AngleSlider(angle: $angle)
}
