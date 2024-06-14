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
        ZStack(alignment: .bottom) {
            renderedView
            controls
        }
        .ignoresSafeArea()
        .onRotate { newOrientation in
            viewModel.rotateDevice(to: newOrientation)
        }
    }
    
    // MARK: - Scene
    
    /// The rendered 3D `SceneView`
    private var renderedView: some View {
        SceneView(
            scene: viewModel.scene,
            pointOfView: viewModel.camera
        )
        .gesture(latLongGesture)
        .onTapGesture {
            withAnimation {
                viewModel.controlVisibility = .bottomButtons
            }
        }
    }
    
    // MARK: - Controls
    
    /// Buttons at the bottom to open controls for angles
    private var controls: some View {
        VStack(spacing: 0) {
            switch viewModel.controlVisibility {
            case .angleControls: eulerAngleControls
            case .latLongControls: latLongAngleControls
            case .bottomButtons: bottomButtons
            }
        }
        .background(.background)
        .cornerRadius(Constants.controlOverlayRadius)
        .padding(Constants.controlOverlayRadius)
    }
    
    private var bottomButtons: some View {
        HStack(spacing: Constants.sliderPadding) {
            Button(action: {
                withAnimation {
                    viewModel.controlVisibility = .angleControls
                }
            }) {
                Image(systemName: "rotate.3d.circle")
            }
            Button(action: {
                withAnimation {
                    viewModel.controlVisibility = .latLongControls
                }
            }) {
                Image(systemName: "globe")
            }
        }
        .font(.largeTitle)
        .padding(Constants.controlOverlayPadding)
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
        Text("Yaw → Pitch → Roll Sequence").font(.headline)
            .angleSliderContextMenu("Yaw → Pitch → Roll", onResetAction: { viewModel.resetYawPitchRollAngles() })
        angleSlider(for: $viewModel.yaw, name: "Yaw", symbol: "ψ")
        angleSlider(for: $viewModel.pitch, name: "Pitch", symbol: "𝜃")
        angleSlider(for: $viewModel.roll, name: "Roll", symbol: "φ")
    }
    
    /// A custom slider using specified angle limits, steps, and labels
    private func angleSlider(for angle: Binding<Float>, name: String = "", symbol: String = "") -> some View {
        ZStack {
            Text("\(symbol) = \(Int(angle.wrappedValue * Constants.rad2deg)) deg")
                .font(.callout)
                .foregroundColor(.secondary)
                .offset(Constants.sliderLabelOffset)
            Slider(
                value: angle,
                in: Constants.angleRange,
                step: Constants.sliderStep,
                label: { Text(name) },
                minimumValueLabel: { Text(viewModel.isLandscape ? "" : minValueString) },
                maximumValueLabel: { Text(viewModel.isLandscape ? "" : maxValueString) }
            )
            .offset(Constants.sliderOffset)
        }
        .frame(height: Constants.sliderHeight)
        .angleSliderContextMenu(name, onResetAction: { angle.wrappedValue = 0 })
    }
    
    /// The lower bound for the slider
    private var minValueString: String {
        String(Int(Constants.angleRange.lowerBound * Constants.rad2deg))
    }
    
    /// The upper bound for a slider
    private var maxValueString: String {
        String(Int(Constants.angleRange.upperBound * Constants.rad2deg))
    }
    
    /// Dimension of the sheet that pops up from the bottom
    private var angleControlsHeight: CGFloat {
        viewModel.isLandscape ? 64 : 212
    }
    
    // MARK: - Latitude/Longitude Angle Controls
    
    @GestureState private var gestureLatLong = GestureLatLongState()
    
    /// Stores the initial latitude and longitude prior to the gesture, the x/y coordinates of the gesture, and provides offset for the center of the crosshair
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
        
        mutating func update(for translation: CGSize, rotatedBy angle: CGFloat = 0) -> GestureLatLongState {
            x = translation.width * cos(angle) - translation.height * sin(angle)
            y = translation.width * sin(angle) + translation.height * cos(angle)
            return GestureLatLongState(
                lat: max(min(lat + 0.05 * Float(y), 90), -90),
                long: long - 0.05 * Float(x)
            )
        }
        
        var offset: CGSize {
            CGSize(width: CGFloat(x), height: CGFloat(y))
        }
    }
    
    /// Handles a drag gesture when the latitude and longitude control is visible
    private var latLongGesture: some Gesture {
        DragGesture()
            .updating($gestureLatLong) { inMotionDragGestureValue, gestureLatLong, _ in
                if gestureLatLong.isFirstUpdate {
                    gestureLatLong.setInitial(lat: viewModel.lat, long: viewModel.long)
                }
                if viewModel.controlVisibility == .latLongControls {
                    let update = gestureLatLong.update(for: inMotionDragGestureValue.translation, rotatedBy: viewModel.cameraAngle)
                    DispatchQueue.main.async {
                        viewModel.setLatLong(lat: update.lat, long: update.long)
                    }
                }
            }
    }

    /// The indicators for the latitude and longitude angles
    @ViewBuilder
    private var latLongAngleControls: some View {
        if viewModel.isLandscape {
            HStack {
                latLongContent
            }
            .padding(Constants.sliderPadding)
            .frame(width: Constants.latLongMenuWidthInLandscape, height: Constants.latLongMenuHeightInLandscape)
        } else {
            VStack {
                latLongContent
            }
            .padding(Constants.sliderPadding)
        }
    }
    
    /// Displays fixed text labeling that you have the latitude/longitude control open
    private var latLongMessage: some View {
        VStack {
            Text("Latitude & Longitude").font(.headline)
            Text("Drag on globe to update").font(.caption)
        }
    }
    
    /// Displays current numerical values for the latitude and longitude
    private var latLongState: some View {
        HStack {
            VStack(alignment: .leading) {
                let format = "%.2f"
                Text("Latitude = \(String(format: format, viewModel.lat)) deg")
                    .angleSliderContextMenu("Latitude", onResetAction: { viewModel.lat = 0 })
                Text("Longitude = \(String(format: format, viewModel.long)) deg")
                    .angleSliderContextMenu("Longitude", onResetAction: { viewModel.long = 0 })
            }
            Spacer()
        }
        .frame(maxWidth: 0.5 * Constants.latLongMenuWidthInLandscape)
    }
    
    
    /// Displays the `latLongMessage` and `latLongState` when the latitude and longitude control is visible
    @ViewBuilder
    private var latLongContent: some View {
        latLongMessage
            .angleSliderContextMenu("Latitude & Longitude", onResetAction: {viewModel.setLatLong(lat: 0, long: 0)})
        Divider()
        latLongState
    }
    
    // MARK: - Constants
    
    private struct Constants {
        static let angleRange = -Float.pi...Float.pi
        static let sliderStep = Float.pi / 180
        static let sliderSpacing = CGFloat(0)
        static let controlOverlayPadding = CGFloat(4)
        static let sliderPadding = CGFloat(12)
        static let controlOverlayRadius = CGFloat(24)
        static let sliderHeight = CGFloat(48)
        static let latLongMenuWidthInLandscape = CGFloat(444)
        static let latLongMenuHeightInLandscape = CGFloat(64)
        static let sliderOffset = CGSize(width: 0, height: -10)
        static let sliderLabelOffset = CGSize(width: 0, height: 14)
        static let rad2deg = 180.0 / Float.pi
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ER3DView(viewModel: ER3DViewModel())
    }
}
