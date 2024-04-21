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
            // Add the 3D rendering view
            SceneView(
                scene: viewController.scene,
                pointOfView: viewController.cameraNode,
                options: [.autoenablesDefaultLighting]
            )
            
            // Add the controls
            VStack(spacing: 12) {
                Slider(value: $viewController.yaw, in: 0...2*Float.pi)
                    .onChange(of: viewController.yaw) { _ in
                        update()
                    }
                Slider(value: $viewController.pitch, in: 0...2*Float.pi)
                    .onChange(of: viewController.pitch) { _ in
                        update()
                    }
                Slider(value: $viewController.roll, in: 0...2*Float.pi)
                    .onChange(of: viewController.roll) { _ in
                        update()
                    }
            }
            .padding(24)
        }
    }
    
    private 
    
    /**
     Update orientation of the ship based on the current Euler angle states
     */
    func update() {
        viewController.update()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewController: ContentViewController())
    }
}
