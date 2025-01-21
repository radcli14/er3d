//
//  BottomButtons.swift
//  ER3D
//
//  Created by Eliott Radcliffe on 1/13/25.
//

import SwiftUI

enum ControlVisibility {
    case bottomButtons, angleControls, latLongControls, settings
}

struct BottomButtons: View {
    @Binding var controlVisibility: ControlVisibility
    
    var body: some View {
        HStack(spacing: Constants.spacing) {
            bottomButton("rotate.3d.circle", visibility: .angleControls)
            bottomButton("globe", visibility: .latLongControls)
            //bottomButton("gear", visibility: .settings)
        }
        .font(.largeTitle)
        .padding(Constants.padding)
    }
    
    /// A button with a system icon that sets the `controlVisibility` to a specified value when tapped
    private func bottomButton(_ systemName: String, visibility: ControlVisibility) -> some View {
        Button {
            withAnimation {
                controlVisibility = visibility
            }
        } label: {
            Image(systemName: systemName)
        }
    }
    
    private struct Constants {
        static let spacing: CGFloat = 12
        static let padding: CGFloat = 4
    }
}

#Preview {
    @Previewable @State var controlVisibility: ControlVisibility = .bottomButtons
    BottomButtons(controlVisibility: $controlVisibility)
}
