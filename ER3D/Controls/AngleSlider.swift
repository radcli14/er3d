//
//  AngleSlider.swift
//  ER3D
//
//  Created by Eliott Radcliffe on 1/13/25.
//

import SwiftUI

/// A custom slider using specified angle limits, steps, and labels
struct AngleSlider: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    @Binding var angle: Float
    let name: String
    let symbol: String
    
    var body: some View {
        ZStack {
            Text("\(symbol) = \(String(format: "%.0f", angle * Constants.rad2deg)) deg")
                .font(.callout)
                .foregroundColor(.secondary)
                .offset(Constants.sliderLabelOffset)
            Slider(
                value: $angle,
                in: Constants.angleRange,
                step: Constants.sliderStep,
                label: { Text(name) },
                minimumValueLabel: { Text(isLandscape ? "" : minValueString) },
                maximumValueLabel: { Text(isLandscape ? "" : maxValueString) }
            )
            .offset(Constants.sliderOffset)
        }
        .frame(height: Constants.sliderHeight)
        .angleSliderContextMenu(name, onResetAction: { angle = 0 })
    }
    
    var isLandscape: Bool {
        verticalSizeClass == .compact
    }
    
    /// The lower bound for the slider
    private var minValueString: String {
        String(Int(Constants.angleRange.lowerBound * Constants.rad2deg))
    }
    
    /// The upper bound for a slider
    private var maxValueString: String {
        String(Int(Constants.angleRange.upperBound * Constants.rad2deg))
    }
    
    private struct Constants {
        static let angleRange = -Float.pi...Float.pi
        static let sliderStep = Float.pi / 180
        static let sliderSpacing = CGFloat(0)
        static let sliderOffset = CGSize(width: 0, height: -10)
        static let sliderLabelOffset = CGSize(width: 0, height: 14)
        static let sliderHeight = CGFloat(48)
        static let rad2deg: Float = 180 / .pi
    }
}

#Preview {
    @Previewable @State var angle = Float(0.0)
    AngleSlider(angle: $angle, name: "Test", symbol: "😀")
}
