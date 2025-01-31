//
//  ER3DControls.swift
//  ER3D
//
//  Created by Eliott Radcliffe on 1/13/25.
//

import SwiftUI
import TipKit

struct ER3DControls: View {
    @Binding var controlVisibility: ControlVisibility
    @Binding var sequence: RotationSequence
    let resetLatLong: (String) -> Void
    let resetScene: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            switch controlVisibility {
            case .angleControls:
                EulerAngleControls(sequence: $sequence)
                    .popoverTip(angleTips.currentTip)
            case .latLongControls:
                LatLongAngleIndicators(sequence: sequence as? HasLatLong) { stateToReset in
                    resetLatLong(stateToReset)
                }
                .popoverTip(angleTips.currentTip)
            case .settings:
                SettingsContent()
            case .bottomButtons:
                BottomButtons(controlVisibility: $controlVisibility) {
                    resetScene()
                }
                .popoverTip(controlTips.currentTip)
            }
        }
        .background(.background)
        .cornerRadius(Constants.controlOverlayRadius)
        .padding(Constants.controlOverlayRadius)
    }
    
    // MARK: - Tips
    
    @State var controlTips = TipGroup(.firstAvailable) {
        [ControlTips.bottomButtons, .eulerAngles, .settings, .reset, .translation, .rotation, .scale]
    }
    @State var angleTips = TipGroup(.firstAvailable) {
        [AngleTips.info, .reset]
    }
    
    // MARK: - Constants
    
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
        resetLatLong: { stateToReset in print("Reset \(stateToReset)") },
        resetScene: {}
    )
    .environment(settings)
}
