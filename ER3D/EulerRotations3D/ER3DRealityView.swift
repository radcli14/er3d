//
//  ER3DRealityView.swift
//  EulerRotations3D
//
//  Created by Eliott Radcliffe on 1/13/25.
//

import SwiftUI
import RealityKit
import StoreKit
import TipKit

struct ER3DRealityView : View {
    @Environment(SettingsContent.ViewModel.self) var settings
    
    /// Handles requesting a review once the user has spent enough time in the app
    @Environment(\.requestReview) var requestReview
    @AppStorage("lastReviewRequestDate") var lastReviewRequestDate: String?
        
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
            .onChange(of: settings.earthVisibility) {
                viewModel.toggleEarth(visible: settings.earthVisibility)
            }
        .onTapGesture {
            withAnimation {
                viewModel.actionCount += 1
                viewModel.controlVisibility = .bottomButtons
                attemptReviewRequest()
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
        .task {
            // Configure and load your tips at app launch.
            do {
                try Tips.configure()/*[
                    .displayFrequency(.hourly)
                ])*/
            }
            catch {
                // Handle TipKit errors
                print("Error initializing TipKit \(error.localizedDescription)")
            }
        }
    }
    
    private var overlayControls: some View {
        VStack {
            ER3DHeader()
            Spacer()
            ER3DControls(
                controlVisibility: $viewModel.controlVisibility,
                sequence: $viewModel.sequence,
                resetLatLong: { stateToReset in viewModel.resetLatLong(stateToReset) },
                resetScene: { viewModel.resetScene() }
            )
        }
    }
    
    // MARK: - Reviews
    
    /// Request a review if the user has taken enough action in the app that they might like it
    func attemptReviewRequest() {
        // Make sure a review hasn't been requested too recently
        let dateFormatter = ISO8601DateFormatter()
        if let lastRequestDateString = lastReviewRequestDate, let lastRequestDate = dateFormatter.date(from: lastRequestDateString) {
            let secondsSinceLastRequest = Date.now.timeIntervalSince(lastRequestDate)
            let secondsInOneDay = Double(24 * 60 * 60)
            if secondsSinceLastRequest < secondsInOneDay {
                return
            }
        }

        // Make sure there is a meaningful amount of user actions
        if viewModel.actionCount > 20 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                requestReview()
                lastReviewRequestDate = dateFormatter.string(from: .now)
            }
        }
    }
}

#Preview {
    @Previewable @State var settings = SettingsContent.ViewModel()
    ER3DRealityView()
        .environment(settings)
}
