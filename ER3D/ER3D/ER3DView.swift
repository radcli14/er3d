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
            eulerAngleControls
                .presentationDetents([.height(angleControlsHeight)])
        }
        .sheet(isPresented: $viewModel.latLongControlsVisible) {
            latLongAngleControls
                .presentationDetents([.height(angleControlsHeight)])
        }
    }
    
    // MARK: - Scene
    
    /// The rendered 3D `SceneView`
    private var renderedView: some View {
        SceneView(
            scene: viewModel.scene,
            pointOfView: viewModel.camera//,
            //options: [.autoenablesDefaultLighting]
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
    
    // MARK: - Euler Angle Controls
    
    /// The stack of three sliders representing the yaw, pitch, and roll angles
    @ViewBuilder
    private var eulerAngleControls: some View {
        if viewModel.isLandscape {
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
        angleSlider(for: $viewModel.yaw, name: "Yaw", symbol: "ψ")
        angleSlider(for: $viewModel.pitch, name: "Pitch", symbol: "𝜃")
        angleSlider(for: $viewModel.roll, name: "Roll", symbol: "φ")
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
    
    // MARK: - Latitude/Longitude Angle Controls
    
    @GestureState private var gestureLatLong = GestureLatLongState()
    
    private struct GestureLatLongState {
        var lat: Float = 0.0
        var long: Float = 0.0
        var x: CGFloat = 0.0
        var y: CGFloat = 0.0
        var isFirstUpdate = true
        
        mutating func setInitial(lat: Float, long: Float) {
            self.long = long
            self.lat = lat
            isFirstUpdate = false
        }
        
        mutating func update(for translation: CGSize, in geometry: GeometryProxy) -> GestureLatLongState {
            x = max(min(translation.width, 0.5 * geometry.size.width), -0.5 * geometry.size.width)
            y = max(min(translation.height, 0.5 * geometry.size.height), -0.5 * geometry.size.height)
            return GestureLatLongState(
                lat: max(min(lat + 0.05 * Float(y), 90), -90),
                long: long + 0.05 * Float(x)
            )
        }
    }

    /// The controls for varying the latitude and longitude angles
    private var latLongAngleControls: some View {
        GeometryReader { geometry in
            latLongPad(in: geometry)
        }
        .padding(Constants.sliderPadding)
    }
    
    /// The drag pad for controlling the latitude and longitude angles
    private func latLongPad(in geometry: GeometryProxy) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: Constants.sliderPadding)
                .foregroundColor(.gray)
            crosshairLine(in: geometry, isVertical: true)
            crosshairLine(in: geometry, isVertical: false)
        }
        .gesture(latLongGesture(in: geometry))
    }
    
    /// Either a vertical or horizontal line depicting the position of the users drag gesture
    private func crosshairLine(in geometry: GeometryProxy, isVertical: Bool) -> some View {
        Rectangle()
            .frame(
                width: isVertical ? Constants.crosshairWidth : geometry.size.width,
                height: isVertical ? geometry.size.height : Constants.crosshairWidth
            )
            .offset(
                x: isVertical ? CGFloat(gestureLatLong.x) : .zero,
                y: isVertical ? .zero : CGFloat(gestureLatLong.y)
            )
    }
    
    private func latLongGesture(in geometry: GeometryProxy) -> some Gesture {
        DragGesture()
            .updating($gestureLatLong) { inMotionDragGestureValue, gestureLatLong, _ in
                if gestureLatLong.isFirstUpdate {
                    gestureLatLong.setInitial(lat: viewModel.lat, long: viewModel.long)
                }
                let update = gestureLatLong.update(for: inMotionDragGestureValue.translation, in: geometry)
                DispatchQueue.main.async {
                    viewModel.setLatLong(lat: update.lat, long: update.long)
                }
            }
    }
    
    
    @ViewBuilder
    private var latLongAngleControlsInStack: some View {
        angleSlider(for: $viewModel.long, name: "Longitude", symbol: "Long.")
        angleSlider(for: $viewModel.lat, name: "Latitude", symbol: "Lat.")
    }
    
    // MARK: - Constants
    
    private struct Constants {
        static let angleRange = -Float.pi...Float.pi
        static let sliderStep = Float.pi / 180
        static let sliderSpacing = CGFloat(24)
        static let sliderPadding = CGFloat(24)
        static let sliderLabelOffset = CGSize(width: 0, height: 24)
        static let rad2deg = 180.0 / Float.pi
        static let crosshairWidth = CGFloat(2)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ER3DView(viewModel: ER3DViewModel())
    }
}
