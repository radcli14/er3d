//
//  EulerAngleControls.swift
//  ER3D
//
//  Created by Eliott Radcliffe on 1/13/25.
//

import SwiftUI

/// The stack of three sliders representing the yaw, pitch, and roll angles
struct EulerAngleControls: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    @Binding var sequence: RotationSequence
    
    var body: some View {
        VStack(spacing: 0) {
            headerLine
            eulerAngleControlsInStack
        }
        .padding(Constants.sliderPadding)
    }
    
    private var headerLine: some View {
        HStack {
            Button {
                sequence.reset()
            } label: {
                Image(systemName: "arrow.counterclockwise.circle.fill")
            }
            Text("\(sequence.name) Sequence")
                .font(.headline)
                .multilineTextAlignment(.center)
            InfoButtonWithPopover(key: sequence.name, isFilled: true)
        }
    }
    
    @ViewBuilder
    private var eulerAngleControlsInStack: some View {
        if isLandscape {
            HStack(spacing: sliderSpacing) {
                eulerAngleControlsList
            }
        } else {
            VStack(spacing: sliderSpacing) {
                eulerAngleControlsList
            }
            .padding(.top)
        }
    }
    
    @ViewBuilder
    private var eulerAngleControlsList: some View {
        AngleSlider(angle: $sequence.first)
        AngleSlider(angle: $sequence.second)
        AngleSlider(angle: $sequence.third)
    }

    private var sliderSpacing: CGFloat {
        isLandscape ? 36 : 12
    }
    
    var isLandscape: Bool {
        verticalSizeClass == .compact
    }
    
    // MARK: - Constants
    
    private struct Constants {
        static let sliderPadding = CGFloat(12)
        static let sliderSpacing = CGFloat(0)
    }
}

#Preview {
    @Previewable @State var sequence: RotationSequence = ProcessionNutationSpinSequence()
    EulerAngleControls(sequence: $sequence)
}
