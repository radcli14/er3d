//
//  ER3DHeader.swift
//  ER3D
//
//  Created by Eliott Radcliffe on 1/13/25.
//

import SwiftUI

struct ER3DHeader: View {
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0) {
                Text("ER3D").font(Font.system(.largeTitle, design: .monospaced, weight: .bold)).cornerRadius(12)
                Text("Euler Rotations in 3-Dimensions").font(.caption2)
            }
            .offset(x: 24, y: 36)
            .foregroundColor(.white)
        }
    }
}

#Preview {
    ER3DHeader()
}
