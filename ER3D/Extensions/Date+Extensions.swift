//
//  Date+Extensions.swift
//  ER3D
//
//  Created by Eliott Radcliffe on 1/22/25.
//

import Foundation

extension Date {
    var utcTimeZone: TimeZone {
        TimeZone(abbreviation: "UTC")!
    }
    
    var gregorianCalendar: Calendar {
        Calendar(identifier: .gregorian)
    }
    
    var utcDateComponents: DateComponents {
        gregorianCalendar.dateComponents(in: utcTimeZone, from: .now)
    }
    
    /// Calculate the day of the year (1-365/366)
    var utcDayOfYear: Int {
        utcDateComponents.day ?? 1
    }
    
    /// Calculate the fractional year (in radians)
    var fractionalYear: Double {
        2.0 * .pi / 365.0 * Double(utcDayOfYear - 1)
    }
    
    /// Calculate the solar declination angle (in degrees)
    var solarElevationAngleDegrees: Double {
        -23.45 * sin(fractionalYear + 2.0 * .pi / 365.0 * Double(utcDayOfYear + 10))
    }
    
    var solarElevationAngleRadians: Float {
        Float(.pi / 180.0 * solarElevationAngleDegrees)
    }
    
    /// Time offset in hours from midnight UTC
    var solarTimeOffset: Double {
        let utcDateComponents = utcDateComponents
        let hour = Double(utcDateComponents.hour ?? 0)
        let minute = Double(utcDateComponents.minute ?? 0)
        return hour + minute / 60.0
    }
    
    var solarTimeOffsetAngleRadians: Float {
        -Float(2.0 * .pi * solarTimeOffset / 24.0)
    }
}
