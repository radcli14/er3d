//
//  BottomButtons.swift
//  ER3D
//
//  Created by Eliott Radcliffe on 1/13/25.
//

import SwiftUI

enum ControlVisibility {
    case bottomButtons, angleControls, latLongControls
}

struct BottomButtons: View {
    @Binding var controlVisibility: ControlVisibility
    
    var body: some View {
        HStack(spacing: Constants.spacing) {
            Button(action: {
                withAnimation {
                    controlVisibility = .angleControls
                }
            }) {
                Image(systemName: "rotate.3d.circle")
            }
            Button(action: {
                withAnimation {
                    controlVisibility = .latLongControls
                }
            }) {
                Image(systemName: "globe")
            }
        }
        .font(.largeTitle)
        .padding(Constants.padding)
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
