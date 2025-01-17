//
//  ER3DControls.swift
//  ER3D
//
//  Created by Eliott Radcliffe on 1/13/25.
//

import SwiftUI

struct ER3DControls: View {
    @Binding var controlVisibility: ControlVisibility
    @Binding var yaw: Float
    @Binding var pitch: Float
    @Binding var roll: Float
    @Binding var lat: Float
    @Binding var long: Float
    let resetYawPitchRollAngles: () -> Void
    let resetLatLong: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            switch controlVisibility {
            case .angleControls:
                EulerAngleControls(yaw: $yaw, pitch: $pitch, roll: $roll) {
                        resetYawPitchRollAngles()
                    }
            case .latLongControls:
                LatLongAngleControls(lat: $lat, long: $long) {
                    resetLatLong()
                }
            case .bottomButtons:
                BottomButtons(controlVisibility: $controlVisibility)
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
    @Previewable @State var controlVisibility = ControlVisibility.bottomButtons
    @Previewable @State var yaw: Float = 0.0
    @Previewable @State var pitch: Float = 0.0
    @Previewable @State var roll: Float = 0.0
    @Previewable @State var lat: Float = 0.0
    @Previewable @State var long: Float = 0.0
    ER3DControls(
        controlVisibility: $controlVisibility,
        yaw: $yaw, pitch: $pitch, roll: $roll, lat: $lat, long: $long,
        resetYawPitchRollAngles: { print("Reset YPR") },
        resetLatLong: { print("Reset Lat/Long") }
    )
}
