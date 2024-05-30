//
//  ContentView.swift
//  ER3D
//
//  Created by Eliott Radcliffe on 9/29/22.
//

import SwiftUI
import SceneKit

struct ER3DView: View {
    @ObservedObject var viewModel: ER3DViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            renderedView
            angleControls
        }
    }
    
    private var renderedView: some View {
        SceneView(
            scene: viewModel.scene,
            pointOfView: viewModel.camera,
            options: [.autoenablesDefaultLighting]
        )
    }
    
    private var angleControls: some View {
        VStack(spacing: Constants.sliderSpacing) {
            Slider(value: $viewModel.yaw, in: Constants.angleRange)
            Slider(value: $viewModel.pitch, in: Constants.angleRange)
            Slider(value: $viewModel.roll, in: Constants.angleRange)
        }
        .padding(Constants.sliderPadding)
    }
    
    private struct Constants {
        static let angleRange = 0...2*Float.pi
        static let sliderSpacing = CGFloat(12)
        static let sliderPadding = CGFloat(24)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ER3DView(viewModel: ER3DViewModel())
    }
}
