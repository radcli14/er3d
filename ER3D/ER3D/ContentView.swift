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
            Slider(value: $viewController.yaw, in: Constants.angleRange)
            Slider(value: $viewController.pitch, in: Constants.angleRange)
            Slider(value: $viewController.roll, in: Constants.angleRange)
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
        ContentView(viewController: ContentViewController())
    }
}
