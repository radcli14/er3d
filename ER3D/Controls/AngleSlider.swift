//
//  AngleSlider.swift
//  ER3D
//
//  Created by Eliott Radcliffe on 1/13/25.
//

import SwiftUI

/// A custom slider using specified angle limits, steps, and labels
struct AngleSlider: View {
    @Binding var angle: Float
    let name: String
    let symbol: String
    var angleRange = -Float.pi...Float.pi
    
    @State private var showInfo = false
    
    var body: some View {
        VStack(spacing: Constants.sliderSpacing) {
            Slider(
                value: $angle,
                in: angleRange,
                step: Constants.sliderStep,
                label: { Text(name) }
            )
            HStack {
                Button {
                    angle = 0
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                }
                Text("\(name) \(symbol) = \(String(format: "%.0f", angle * Constants.rad2deg)) deg")
                    .font(.callout)
                    .foregroundColor(.secondary)
                Spacer()
                Button {
                    showInfo = true
                } label: {
                    Image(systemName: "info.bubble")
                }
                .popover(isPresented: $showInfo) {
                    PopoverContent(key: name)
                }
            }
        }
        //.padding(.top)
    }
    
    private struct Constants {
        static let sliderStep: Float = .pi / 180
        static let sliderSpacing: CGFloat = 0
        static let rad2deg: Float = 180 / .pi
    }
}

#Preview {
    @Previewable @State var angle = Float(0.0)
    AngleSlider(angle: $angle, name: "Test", symbol: "😀")
}
