//
//  ContentView.swift
//  ER3D
//
//  Created by Eliott Radcliffe on 9/29/22.
//

import SwiftUI
import SceneKit

struct ContentView: View {
    var viewController: ContentViewController
    
    var body: some View {
        ZStack {
            // Add the 3D rendering view
            SceneView(
                scene: viewController.scene,
                pointOfView: viewController.cameraNode,
                options: [.autoenablesDefaultLighting, .allowsCameraControl]
            )

            Text("This is me")
                .foregroundColor(Color.green)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewController: ContentViewController())
    }
}
