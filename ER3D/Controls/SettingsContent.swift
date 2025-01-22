//
//  SettingsContent.swift
//  ER3D
//
//  Created by Eliott Radcliffe on 1/22/25.
//

import SwiftUI
import RealityKit

enum EulerSequence {
    case yawPitchRoll
    case processionNutationSpin
}

struct SettingsContent: View {
    @Environment(SettingsContent.ViewModel.self) var settings
    
    @Observable class ViewModel {
        var cameraMode = ARView.CameraMode.nonAR
        var sequence = EulerSequence.yawPitchRoll
        var earthVisibility = true
        var frameVisibility = true
    }
    
    var body: some View {
        VStack {
            Text("Settings")
                .font(.headline)
            Form {
                cameraModePicker
                eulerSequencePicker
                visibilitySection
            }
            .pickerStyle(.segmented)
        }
        .padding()
    }
    
    @ViewBuilder
    private var cameraModePicker: some View {
        @Bindable var viewModel = settings
        Section("Camera Mode") {
            Picker("", selection: $viewModel.cameraMode) {
                Text("Standard").tag(ARView.CameraMode.nonAR)
                Text("AR").tag(ARView.CameraMode.ar)
            }
        }
    }
    
    @ViewBuilder
    private var eulerSequencePicker: some View {
        @Bindable var viewModel = settings
        Section("Euler Sequence") {
            Picker("", selection: $viewModel.sequence) {
                Text("3-2-1").tag(EulerSequence.yawPitchRoll)
                Text("3-1-3").tag(EulerSequence.processionNutationSpin)
            }
        }
    }
    
    @ViewBuilder
    private var visibilitySection: some View {
        @Bindable var viewModel = settings
        Section("Visibility") {
            Toggle(isOn: $viewModel.earthVisibility) { Text("Earth") }
            Toggle(isOn: $viewModel.frameVisibility) { Text("Frames") }
        }
    }
}

#Preview {
    @Previewable @State var settings = SettingsContent.ViewModel()
    SettingsContent()
        .environment(settings)
}
