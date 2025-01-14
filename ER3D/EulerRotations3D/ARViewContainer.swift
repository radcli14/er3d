//
//  ARViewContainer.swift
//  ER3D
//
//  Created by Eliott Radcliffe on 1/14/25.
//

import Foundation
import SwiftUI
import RealityKit

struct ARViewContainer: UIViewRepresentable {
    @State var viewModel: ER3DRealityViewModel
    
    func makeUIView(context: Context) -> ARView {
        return viewModel.arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}
