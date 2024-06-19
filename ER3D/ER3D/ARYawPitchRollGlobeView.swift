//
//  ARYawPitchRollGlobeView.swift
//  ER3D
//
//  Created by Eliott Radcliffe on 6/17/24.
//

import SwiftUI
import RealityKit

struct ARYawPitchRollGlobeView: View {
    var body: some View {
        let entity = try? Entity.load(named: "art/globe.usda")
        //ARView
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    ARYawPitchRollGlobeView()
}
