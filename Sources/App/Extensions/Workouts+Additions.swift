//
//  File.swift
//  
//
//  Created by Jeremy Greenwood on 3/12/20.
//

import Foundation

extension Array where Element == Workout {
    var totalDuration: TimeInterval {
        reduce(0.0) { $0 + $1.duration }
    }
}
