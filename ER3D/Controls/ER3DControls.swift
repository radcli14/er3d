//
//  ER3DControls.swift
//  ER3D
//
//  Created by Eliott Radcliffe on 1/13/25.
//

import SwiftUI

struct ER3DControls: View {
    @Binding var controlVisibility: ControlVisibility
    @Binding var sequence: RotationSequence
    let lat: Float
    let long: Float
    let resetYawPitchRollAngles: () -> Void
    let resetLatLong: (String) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            switch controlVisibility {
            case .angleControls:
                EulerAngleControls(sequence: $sequence)
            case .latLongControls:
                LatLongAngleIndicators(lat: lat, long: long) { stateToReset in
                    resetLatLong(stateToReset)
                }
            case .settings:
                SettingsContent()
            case .bottomButtons:
                BottomButtons(controlVisibility: $controlVisibility, settingsAreAvailable: true)
            }
        }
        .background(.background)
        .cornerRadius(Constants.controlOverlayRadius)
        .padding(Constants.controlOverlayRadius)
    }
    
    private struct Constants {
        static let controlOverlayPadding = CGFloat(4)
        static let controlOverlayRadius = CGFloat(24)
    }
}

#Preview {
    @Previewable @State var settings = SettingsContent.ViewModel()
    @Previewable @State var controlVisibility = ControlVisibility.bottomButtons
    @Previewable @State var sequence: RotationSequence = ProcessionNutationSpinSequence()
    ER3DControls(
        controlVisibility: $controlVisibility,
        sequence: $sequence,
        lat: 0, long: 0,
        resetYawPitchRollAngles: { print("Reset YPR") },
        resetLatLong: { stateToReset in print("Reset \(stateToReset)") }
    )
    .environment(settings)
}
