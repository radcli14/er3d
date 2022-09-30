//
//  ER3DApp.swift
//  ER3D
//
//  Created by Eliott Radcliffe on 9/29/22.
//

import SwiftUI

@main
struct ER3DApp: App {
    let viewController = ContentViewController()
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewController: viewController)
        }
    }
}
