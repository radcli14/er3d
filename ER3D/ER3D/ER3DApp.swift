//
//  ER3DApp.swift
//  ER3D
//
//  Created by Eliott Radcliffe on 9/29/22.
//

import SwiftUI

@main
struct ER3DApp: App {
    @StateObject var viewController = ER3DViewModel()
    
    var body: some Scene {
        WindowGroup {
            ER3DView(viewModel: viewController)
        }
    }
}
