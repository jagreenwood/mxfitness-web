//
//  User+Client.swift
//  
//
//  Created by Jeremy Greenwood on 3/6/20.
//

import Foundation

public struct UserCreate: Codable, Equatable {
    public var name: String
    public var email: String
    public var password: String
}

public struct UserResponse: Codable, Equatable {
    public enum CodingKeys: String, CodingKey {
        case id, name, email, avatar, role, workouts
        case totalWorkoutCount = "total_workout_count"
        case totalWorkoutDuration = "total_workout_duration"
    }

    public let id: String
    public let name: String
    public let email: String
    public let avatar: URL
    public let role: String
    public let totalWorkoutCount: Int
    public let totalWorkoutDuration: TimeInterval
    public let workouts: [WorkoutResponse]
}

public struct UserLogin: Codable {
    public let username: String
    public let password: String

    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }
}
