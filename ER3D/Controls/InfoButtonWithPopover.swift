//
//  InfoButtonWithPopover.swift
//  ER3D
//
//  Created by Eliott Radcliffe on 1/22/25.
//

import SwiftUI

struct InfoButtonWithPopover: View {
    let key: String
    var isFilled = false
    @State private var showInfo = false
    
    var body: some View {
        Button {
            showInfo = true
        } label: {
            Image(systemName: isFilled ? "info.circle.fill" : "info.bubble")
        }
        .popover(isPresented: $showInfo) {
            PopoverContent(key: key)
        }
    }
}

#Preview {
    InfoButtonWithPopover(key: "Latitude")
}
