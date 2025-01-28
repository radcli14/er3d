//
//  ER3DRealityView.swift
//  EulerRotations3D
//
//  Created by Eliott Radcliffe on 1/13/25.
//

import SwiftUI
import RealityKit

struct ER3DRealityView : View {
    @Environment(SettingsContent.ViewModel.self) var settings
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
            .onChange(of: settings.cameraMode) {
                viewModel.toggleTo(settings.cameraMode)
            }
            .onChange(of: settings.sequence) {
                viewModel.toggleTo(settings.sequence)
                viewModel.toggleFrames(visible: settings.frameVisibility) // Toggle frames here to make sure they match the global setting
            }
            .onChange(of: settings.frameVisibility) {
                viewModel.toggleFrames(visible: settings.frameVisibility)
            }
        .onTapGesture {
            withAnimation {
                viewModel.controlVisibility = .bottomButtons
            }
        }
        .onChange(of: viewModel.controlVisibility) {
            viewModel.handleControlVisibilityChange()
        }
        .latLongRaycastGesture { touchPoint in
            viewModel.handleDragGesture(at: touchPoint)
        }
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
                sequence: $viewModel.sequence,
                resetLatLong: { stateToReset in viewModel.resetLatLong(stateToReset) }
            )
        }
    }
}

#Preview {
    @Previewable @State var settings = SettingsContent.ViewModel()
    ER3DRealityView()
        .environment(settings)
}
