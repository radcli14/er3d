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

    var body: some View {
        VStack {
            renderedView
            controls
        }
        .onRotate { newOrientation in
            viewModel.rotateDevice(to: newOrientation)
        }
        .sheet(isPresented: $viewModel.angleControlsVisible) {
            angleControls
                .presentationDetents([.height(angleControlsHeight)])
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
    
    // MARK: - Controls
    
    /// Buttons at the bottom to open controls for angles
    private var controls: some View {
        HStack(spacing: Constants.sliderSpacing) {
            Button(action: { viewModel.angleControlsVisible.toggle() }) {
                Image(systemName: "rotate.3d.circle")
            }
            Button(action: { viewModel.latLongControlsVisible.toggle() }) {
                Image(systemName: "globe")
            }
        }
        .font(.largeTitle)
    }
    
    // MARK: - Angle Controls
    
    /// The stack of three sliders representing the yaw, pitch, and roll angles
    @ViewBuilder
    private var angleControls: some View {
        if viewModel.isLandscape {
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
            minimumValueLabel: { Text(viewModel.isLandscape ? "" : minValueString) },
            maximumValueLabel: { Text(viewModel.isLandscape ? "" : maxValueString) }
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
        String(Int(Constants.angleRange.lowerBound * Constants.rad2deg))
    }
    
    /// The upper bound for a slider
    private var maxValueString: String {
        String(Int(Constants.angleRange.upperBound * Constants.rad2deg))
    }
    
    private var angleControlsHeight: CGFloat {
        viewModel.isLandscape ? 64 : 180
    }
    
    // MARK: - Constants
    
    private struct Constants {
        static let angleRange = -Float.pi...Float.pi
        static let sliderStep = Float.pi / 180
        static let sliderSpacing = CGFloat(24)
        static let sliderPadding = CGFloat(24)
        static let sliderLabelOffset = CGSize(width: 0, height: 24)
        static let rad2deg = 180.0 / Float.pi
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ER3DView(viewModel: ER3DViewModel())
    }
}
