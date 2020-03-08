//
//  File.swift
//  
//
//  Created by Jeremy Greenwood on 3/7/20.
//

import Foundation

extension Array where Element == Challenge {
    func responses() throws -> [ChallengeResponse] {
        return try map { try $0.response() }
    }
}

extension Challenge {
    func response() throws -> ChallengeResponse {
        try ChallengeResponse(id: requireID().uuidString, name: name, startDate: startDate, endDate: endDate, users: users.responses())
    }
}

extension Array where Element == User {
    func responses() throws -> [UserResponse] {
        return try map { try $0.response() }
    }
}

extension User {
    func response() throws -> UserResponse {
        try UserResponse(id: requireID().uuidString, name: name, email: email, role: role.rawValue, workouts: workouts.responses())
    }
}

extension Array where Element == Workout {
    func responses() throws -> [WorkoutResponse] {
        return try map { try $0.response() }
    }
}

extension Workout {
    func response() throws -> WorkoutResponse {
        try WorkoutResponse(id: requireID().uuidString, duration: duration, type: type.rawValue, user: user.response(), challenge: challenge.response())
    }
}
