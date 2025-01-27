//
//  LatLongGesture.swift
//  ER3D
//
//  Created by Eliott Radcliffe on 1/17/25.
//

import Foundation
import SwiftUI

struct LatLongRaycastGesture: ViewModifier {
    let handleDragGesture: (CGPoint) -> Void
    
    @GestureState private var touchPoint: CGPoint?
    
    func body(content: Content) -> some View {
        content
            .gesture(gesture)
    }
    
    var gesture: some Gesture {
        DragGesture()
            .updating($touchPoint) { inMotionDragGestureValue, touchPoint, _ in
                touchPoint = inMotionDragGestureValue.location
                if let touchPoint {
                    handleDragGesture(touchPoint)
                }
            }
    }
}

struct LatLongGesture: ViewModifier {
    let isActive: Bool
    let initialLat: Float
    let initialLong: Float
    var cameraAngle: CGFloat = 0
    var scale: Float = 0.05
    let onUpdate: (Float, Float) -> Void
    
    @GestureState var gestureLatLong: GestureLatLongState = GestureLatLongState()
    
    func body(content: Content) -> some View {
        content
            .gesture(gesture)
    }
    
    var gesture: some Gesture {
        DragGesture()
            .updating($gestureLatLong) { inMotionDragGestureValue, gestureLatLong, _ in
                if gestureLatLong.isFirstUpdate {
                    gestureLatLong.setInitial(lat: initialLat, long: initialLong)
                }
                if isActive {
                    let update = gestureLatLong.update(
                        for: inMotionDragGestureValue.translation, rotatedBy: cameraAngle,
                        scale: scale
                    )
                    DispatchQueue.main.async {
                        withAnimation {
                            onUpdate(update.lat, update.long)
                        }
                    }
                }
            }
            .onEnded { finalDragGestureValue in
                /*if viewModel.controlVisibility == .latLongControls {
                    var gesture = gestureLatLong
                    gesture.setInitial(lat: viewModel.lat, long: viewModel.long)
                    let update = gesture.update(for: finalDragGestureValue.velocity, rotatedBy: viewModel.cameraAngle)
                    DispatchQueue.main.async {
                        withAnimation {
                            viewModel.setLatLong(lat: update.lat, long: update.long)
                        }
                    }
                }*/
            }
    }
}

extension View {
    
    @ViewBuilder
    func latLongRaycastGesture(handleDragGesture: @escaping (CGPoint) -> Void) -> some View {
        let gesture = LatLongRaycastGesture(handleDragGesture: handleDragGesture)
        modifier(gesture)
    }
    
    @ViewBuilder
    func latLongGesture(
        isActive: Bool,
        initialLat: Float,
        initialLong: Float,
        cameraAngle: CGFloat = 0,
        scale: Float = 0.05,
        onUpdate: @escaping (Float, Float) -> Void
    ) -> some View {
        let gesture = LatLongGesture(
            isActive: isActive,
            initialLat: initialLat,
            initialLong: initialLong,
            cameraAngle: cameraAngle,
            scale: scale,
            onUpdate: onUpdate
        )
        modifier(gesture)
    }
}

/// Stores the initial latitude and longitude prior to the gesture, the x/y coordinates of the gesture, and provides offset for the center of the crosshair
struct GestureLatLongState {
    var lat: Float = 0.0
    var long: Float = 0.0
    var x: CGFloat = 0.0
    var y: CGFloat = 0.0
    var isFirstUpdate = true
    
    mutating func setInitial(lat: Float, long: Float) {
        self.long = long
        self.lat = lat
        isFirstUpdate = false
    }
    
    mutating func update(for translation: CGSize, rotatedBy angle: CGFloat = 0, scale: Float = 0.05) -> GestureLatLongState {
        x = translation.width * cos(angle) - translation.height * sin(angle)
        y = translation.width * sin(angle) + translation.height * cos(angle)
        return GestureLatLongState(
            lat: max(min(lat + scale * Float(y), 89), -89),
            long: long - scale * Float(x)
        )
    }
    
    var offset: CGSize {
        CGSize(width: CGFloat(x), height: CGFloat(y))
    }
}
