//
//  LatLongAngleControls.swift
//  ER3D
//
//  Created by Eliott Radcliffe on 1/13/25.
//

import SwiftUI

struct LatLongAngleControls: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Binding var lat: Float
    @Binding var long: Float
    let onResetAction: () -> Void
    
    var body: some View {
        if isLandscape {
            HStack {
                latLongContent
            }
            .padding(Constants.padding)
            .frame(width: Constants.latLongMenuWidthInLandscape, height: Constants.latLongMenuHeightInLandscape)
        } else {
            VStack {
                latLongContent
            }
            .padding(Constants.padding)
        }
    }
    
    var isLandscape: Bool {
        verticalSizeClass == .compact
    }
    
    /// Displays the `latLongMessage` and `latLongState` when the latitude and longitude control is visible
    @ViewBuilder
    private var latLongContent: some View {
        latLongMessage
        Divider()
        latLongState
    }
    
    /// Displays fixed text labeling that you have the latitude/longitude control open
    private var latLongMessage: some View {
        HStack {
            Button {
                onResetAction()
            } label: {
                Image(systemName: "arrow.counterclockwise.circle.fill")
            }
            
            VStack {
                Text("Latitude & Longitude").font(.headline)
                Text("Drag on globe to update").font(.caption)
            }
            InfoButtonWithPopover(key: "Latitude & Longitude", isFilled: true)
        }
        .frame(maxWidth: isLandscape ? 0.5 * Constants.latLongMenuWidthInLandscape : .infinity)
    }
    
    /// Displays current numerical values for the latitude and longitude
    private var latLongState: some View {
        VStack(alignment: .leading) {
            StateLabel(key: "Latitude", state: $lat)
            StateLabel(key: "Longitude", state: $long)
        }
        .frame(maxWidth: isLandscape ? 0.5 * Constants.latLongMenuWidthInLandscape : .infinity)
    }
    
    private func StateLabel(key: String, state: Binding<Float>) -> some View {
        HStack {
            Button {
                state.wrappedValue = 0
            } label: {
                Image(systemName: "arrow.counterclockwise")
            }
            Text("\(key) = \(String(format: "%.2f", state.wrappedValue)) deg")
            Spacer()
            InfoButtonWithPopover(key: key)
        }
    }
    
    private struct Constants {
        static let padding: CGFloat = 12
        static let latLongMenuWidthInLandscape = CGFloat(640)
        static let latLongMenuHeightInLandscape = CGFloat(64)
        static let rad2deg: Float = 180 / .pi
    }
}

#Preview {
    @Previewable @State var lat: Float = 0
    @Previewable @State var long: Float = 0
    LatLongAngleControls(lat: $lat, long: $long) {
        print("Reset")
    }
}
