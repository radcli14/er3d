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
            controls
            ER3DHeader()
        }
        .ignoresSafeArea()
        .onRotate { newOrientation in
            viewModel.rotateDevice(to: newOrientation)
        }
    }
    
    // MARK: - Scene
    
    /// The rendered 3D `SceneView`
    private var renderedView: some View {
        SceneView(
            scene: viewModel.scene,
            pointOfView: viewModel.camera
        )
        .latLongGesture(
            isActive: viewModel.controlVisibility == .latLongControls,
            initialLat: viewModel.lat,
            initialLong: viewModel.long,
            cameraAngle: viewModel.cameraAngle,
            onUpdate: { (lat, long) in viewModel.setLatLong(lat: lat, long: long) }
        )
        .onTapGesture {
            withAnimation {
                viewModel.controlVisibility = .bottomButtons
            }
        }
    }
    
    // MARK: - Controls
    
    /// Buttons at the bottom to open controls for angles
    private var controls: some View {
        ER3DControls(
            controlVisibility: $viewModel.controlVisibility,
            yaw: $viewModel.yaw,
            pitch: $viewModel.pitch,
            roll: $viewModel.roll,
            lat: $viewModel.lat,
            long: $viewModel.long,
            resetYawPitchRollAngles: viewModel.resetYawPitchRollAngles,
            resetLatLong: viewModel.resetLatLong
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ER3DView(viewModel: ER3DViewModel())
    }
}
