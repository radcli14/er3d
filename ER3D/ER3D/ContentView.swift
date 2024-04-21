//
//  ContentView.swift
//  ER3D
//
//  Created by Eliott Radcliffe on 9/29/22.
//

import SwiftUI
import SceneKit

struct ContentView: View {
    @ObservedObject var viewController: ContentViewController

    var body: some View {
        ZStack(alignment: .bottom) {
            renderedView
            angleControls
        }
    }
    
    private var renderedView: some View {
        SceneView(
            scene: viewController.scene,
            pointOfView: viewController.cameraNode,
            options: [.autoenablesDefaultLighting]
        )
    }
    
    private var angleControls: some View {
        VStack(spacing: Constants.sliderSpacing) {
            AngleSlider(angle: $viewController.yaw, update: viewController.update)
            AngleSlider(angle: $viewController.pitch, update: viewController.update)
            AngleSlider(angle: $viewController.roll, update: viewController.update)
        }
        .padding(Constants.sliderPadding)
    }
    
    private struct Constants {
        static let sliderSpacing = CGFloat(12)
        static let sliderPadding = CGFloat(24)
    }
}

struct AngleSlider: View {
    @Binding var angle: Float
    let update: () -> Void
    
    private let angleRange = 0...2*Float.pi
    
    var body: some View {
        Slider(value: $angle, in: angleRange)
            .onChange(of: angle) { _ in
                update()
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewController: ContentViewController())
    }
}
