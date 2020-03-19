//
//  File.swift
//  
//
//  Created by Jeremy Greenwood on 3/7/20.
//

import Foundation
import Vapor

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
        guard let md5 = email.md5, let avatar = URL(string: "https://www.gravatar.com/avatar/\(md5)?s=200") else {
            throw Abort(.internalServerError)
        }

        return try UserResponse(id: requireID().uuidString, name: name, email: email, avatar: avatar, role: role.rawValue, totalWorkoutCount: $workouts.wrappedValue.count,
                         totalWorkoutDuration: $workouts.wrappedValue.totalDuration, workouts: $workouts.wrappedValue.responses())
    }
}

extension Array where Element == Workout {
    func responses() throws -> [WorkoutResponse] {
        return try map { try $0.response() }
    }
}

extension Workout {
    func response() throws -> WorkoutResponse {
        try WorkoutResponse(id: requireID().uuidString, duration: duration, type: type, user: user.response(), challenge: challenge.response())
    }
}
