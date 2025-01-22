//
//  ER3DRealityView.swift
//  EulerRotations3D
//
//  Created by Eliott Radcliffe on 1/13/25.
//

import SwiftUI
import RealityKit

struct ER3DRealityView : View {
    @State var viewModel = ER3DRealityViewModel()
    
    var body: some View {
        /*
        RealityView { content in
            // Create horizontal plane anchor for the content
            let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
            
            // Add the horizontal plane anchor to the scene
            anchor.addChild(viewModel.globe)
            
            // Enable gestures on the globe model
            viewModel.globe.generateCollisionShapes(recursive: true)
            content.add(anchor)

            content.camera = .spatialTracking

        }
         */
        ARViewContainer(viewModel: viewModel)
        .onTapGesture {
            withAnimation {
                viewModel.controlVisibility = .bottomButtons
            }
        }
        .onChange(of: viewModel.controlVisibility) {
            viewModel.handleControlVisibilityChange()
        }
        .latLongGesture(
            isActive: viewModel.controlVisibility == .latLongControls,
            initialLat: viewModel.lat,
            initialLong: viewModel.long,
            scale: viewModel.latLongScale,
            onUpdate: { (lat, long) in
                viewModel.lat = lat
                viewModel.long = long
            }
        )
        .overlay {
            overlayControls
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    private var overlayControls: some View {
        VStack {
            ER3DHeader()
            Spacer()
            ER3DControls(
                controlVisibility: $viewModel.controlVisibility,
                yaw: $viewModel.yaw,
                pitch: $viewModel.pitch,
                roll: $viewModel.roll,
                lat: $viewModel.lat,
                long: $viewModel.long,
                resetYawPitchRollAngles: viewModel.resetYawPitchRollAngles,
                resetLatLong: viewModel.resetLatLong
            )
        }
    }
}

#Preview {
    @Previewable @State var settings = SettingsContent.ViewModel()
    ER3DRealityView()
        .environment(settings)
}
