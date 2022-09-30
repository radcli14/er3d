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
    @State var yaw: Float = 0
    @State var pitch: Float = 0
    @State var roll: Float = 0
    
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
                Slider(value: $yaw, in: 0...2*Float.pi)
                    .onChange(of: yaw) { _ in
                        update()
                    }
                Slider(value: $pitch, in: 0...2*Float.pi)
                    .onChange(of: pitch) { _ in
                        update()
                    }
                Slider(value: $roll, in: 0...2*Float.pi)
                    .onChange(of: roll) { _ in
                        update()
                    }
            }
            .padding(24)
        }
    }
    
    /**
     Update orientation of the ship based on the current Euler angle states
     */
    func update() {
        viewController.update(yaw, pitch, roll)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewController: ContentViewController())
    }
}
