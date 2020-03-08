//
//  File.swift
//  
//
//  Created by Jeremy Greenwood on 3/6/20.
//

import Fluent
import Vapor

enum WorkoutType: String, CaseIterable, Codable {
    case run
    case walk
    case hike
    case yoga
}
