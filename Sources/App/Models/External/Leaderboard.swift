//
//  File.swift
//  
//
//  Created by Jeremy Greenwood on 3/12/20.
//

import Foundation

public struct Leaderboard: Codable, Equatable {
    private enum CodingKeys: String, CodingKey {
        case name
        case totalCount = "total_count_users"
        case totalDuration = "total_duration_users"
    }

    public let name: String
    public let totalCount: [LeaderboardUser]
    public let totalDuration: [LeaderboardUser]
}

public struct LeaderboardUser: Codable, Equatable {
    private enum CodingKeys: String, CodingKey {
        case id, name
        case totalWorkoutCount = "total_workout_count"
        case totalWorkoutDuration = "total_workout_duration"
    }

    public let id: UUID
    public let name: String
    public let totalWorkoutCount: Int
    public let totalWorkoutDuration: TimeInterval
}
