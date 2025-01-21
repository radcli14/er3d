//
//  PopoverContent.swift
//  ER3D
//
//  Created by Eliott Radcliffe on 1/21/25.
//

import SwiftUI

struct PopoverContent: View {
    var key: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(key).font(.title)
                Text(variableDescriptions[key] ?? key)
            }
            .padding()
        }
        .presentationCompactAdaptation(.popover)
    }
}

#Preview {
    PopoverContent(key: "Yaw")
}
