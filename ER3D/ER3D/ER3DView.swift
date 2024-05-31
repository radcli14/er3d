//
//  ContentView.swift
//  ER3D
//
//  Created by Eliott Radcliffe on 9/29/22.
//

import SwiftUI
import SceneKit

struct ER3DView: View {
    @ObservedObject var viewModel: ER3DViewModel
    @State private var isLandscape = false

    var body: some View {
        VStack {
            renderedView
            angleControls
        }
        .onRotate { newOrientation in
            isLandscape = newOrientation == .landscapeLeft || newOrientation == .landscapeRight
        }
    }
    
    // MARK: - Scene
    
    /// The rendered 3D `SceneView`
    private var renderedView: some View {
        SceneView(
            scene: viewModel.scene,
            pointOfView: viewModel.camera,
            options: [.autoenablesDefaultLighting]
        )
    }
    
    // MARK: - Angle Controls
    
    /// The stack of three sliders representing the yaw, pitch, and roll angles
    @ViewBuilder
    private var angleControls: some View {
        if isLandscape {
            HStack {
                angleSlider(for: $viewModel.yaw, name: "Yaw", symbol: "ψ")
                angleSlider(for: $viewModel.pitch, name: "Pitch", symbol: "𝜃")
                angleSlider(for: $viewModel.roll, name: "Roll", symbol: "φ")
            }
            .padding(.bottom, Constants.sliderPadding)
        } else {
            VStack(spacing: Constants.sliderSpacing) {
                angleSlider(for: $viewModel.yaw, name: "Yaw", symbol: "ψ")
                angleSlider(for: $viewModel.pitch, name: "Pitch", symbol: "𝜃")
                angleSlider(for: $viewModel.roll, name: "Roll", symbol: "φ")
            }
            .padding(Constants.sliderPadding)
        }
        
    }
    
    /// A custom slider using specified angle limits, steps, and labels
    private func angleSlider(for angle: Binding<Float>, name: String = "", symbol: String = "") -> some View {
        Slider(
            value: angle,
            in: Constants.angleRange,
            step: Constants.sliderStep,
            label: { Text(name) },
            minimumValueLabel: { Text(isLandscape ? "" : minValueString) },
            maximumValueLabel: { Text(isLandscape ? "" : maxValueString) }
        )
        .background {
            Text("\(symbol) = \(Int(angle.wrappedValue * 180 / Float.pi)) deg")
                .font(.callout)
                .foregroundColor(.secondary)
                .offset(Constants.sliderLabelOffset)
        }
    }
    
    /// The lower bound for the slider
    private var minValueString: String {
        String(Int(Constants.angleRange.lowerBound * 180 / Float.pi))
    }
    
    /// The upper bound for a slider
    private var maxValueString: String {
        String(Int(Constants.angleRange.upperBound * 180 / Float.pi))
    }
    
    // MARK: - Constants
    
    private struct Constants {
        static let angleRange = -Float.pi...Float.pi
        static let sliderStep = Float.pi / 180
        static let sliderSpacing = CGFloat(24)
        static let sliderPadding = CGFloat(24)
        static let sliderLabelOffset = CGSize(width: 0, height: 24)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ER3DView(viewModel: ER3DViewModel())
    }
}
