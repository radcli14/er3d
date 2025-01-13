//
//  ContentView.swift
//  EulerRotations3D
//
//  Created by Eliott Radcliffe on 1/13/25.
//

import SwiftUI
import RealityKit

struct ContentView : View {
    @State var controlVisibility: ControlVisibility = .bottomButtons
    
    @State var yaw: Float = 0.0
    @State var pitch: Float = 0.0
    @State var roll: Float = 0.0
    @State var lat: Float = 0.0
    @State var long: Float = 0.0
    
    @State var globe: Entity?
    
    var body: some View {
        RealityView { content in
            // Load the globe model, and rotate its Root entity so the north pole (Z-axis) faces upward
            globe = try? await Entity(named: "globe")
            let root = globe?.findEntity(named: "Root")!
            root!.transform = Transform(pitch: -.pi / 2)
            print("got the root")

            // Create horizontal plane anchor for the content
            let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
            
            // Add the horizontal plane anchor to the scene
            anchor.addChild(root!)
            content.add(anchor)

            content.camera = .spatialTracking

        }
        .overlay {
            overlayControls
        }
        .onTapGesture {
            withAnimation {
                controlVisibility = .bottomButtons
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    private var overlayControls: some View {
        VStack {
            ER3DHeader()
            Spacer()
            ER3DControls(
                controlVisibility: $controlVisibility,
                yaw: $yaw,
                pitch: $pitch,
                roll: $roll,
                lat: $lat,
                long: $long,
                resetYawPitchRollAngles: resetYawPitchRollAngles,
                resetLatLong: resetLatLong
            )
            .onChange(of: yaw) {
                print("globe = \(globe)")
                guard let yawFrame = globe?.findEntity(named: "YawFrame") else {
                    print("failed to get yawFrame")
                    return
                }
                print("setting yawFrame angle to \(yaw)")
                yawFrame.transform = Transform(yaw: yaw)
            }
        }
    }
    
    private func resetYawPitchRollAngles() {
        yaw = 0.0
        pitch = 0.0
        roll = 0.0
    }
    
    private func resetLatLong() {
        lat = 0.0
        long = 0.0
    }
}

#Preview {
    ContentView()
}
