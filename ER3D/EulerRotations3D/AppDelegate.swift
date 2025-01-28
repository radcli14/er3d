//
//  AppDelegate.swift
//  EulerRotations3D
//
//  Created by Eliott Radcliffe on 1/13/25.
//

import UIKit
import SwiftUI

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var settings: SettingsContent.ViewModel?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Initialize with settings representing the saved state
        loadState()
        let viewModel = ER3DRealityViewModel(with: settings!)
        
        // Create the SwiftUI view that provides the window contents.
        let contentView = ER3DRealityView(viewModel: viewModel)
            .environment(settings!)

        // Use a UIHostingController as window root view controller.
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIHostingController(rootView: contentView)
        self.window = window
        window.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        saveState()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    // MARK: - Save and Load State

    private let cameraModeKey = "cameraMode"
    private let sequenceKey = "sequence"
    private let frameVisibilityKey = "frameVisibility"
    
    /// Save this session's state to `UserDefaults`
    private func saveState() {
        if let settings {
            let cameraModeString = String(describing: settings.cameraMode)
            UserDefaults.standard.set(cameraModeString, forKey: cameraModeKey)
            let sequenceString = String(describing: settings.sequence)
            UserDefaults.standard.set(sequenceString, forKey: sequenceKey)
            UserDefaults.standard.set(settings.frameVisibility, forKey: frameVisibilityKey)
        }
    }
    
    /// Load the saved state from prior sessions from `UserDefaults`
    private func loadState() {
        // Initialize the settings with defaults
        settings = SettingsContent.ViewModel()
        guard let settings else { return }
        
        // Camera Mode
        if let cameraModeString = UserDefaults.standard.string(forKey: cameraModeKey) {
            settings.cameraMode = cameraModeString == "ar" ? .ar : .nonAR
        }
        
        // Euler Sequence
        switch UserDefaults.standard.string(forKey: sequenceKey) {
        case "yawPitchRoll": settings.sequence = .yawPitchRoll
        case "processionNutationSpin": settings.sequence = .processionNutationSpin
        default: break
        }
        
        // Frame Visibility
        settings.frameVisibility = UserDefaults.standard.bool(forKey: frameVisibilityKey)
    }
}

