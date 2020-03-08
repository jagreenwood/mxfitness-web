//
//  Workout+Client.swift
//  
//
//  Created by Jeremy Greenwood on 3/7/20.
//

import Foundation

public struct WorkoutResponse: Codable, Equatable {
    private enum CodingKeys: String, CodingKey {
        case id, duration, type
        case user, challenge
    }

    public let id: String
    public let duration: TimeInterval
    public let type: String
    public let user: UserResponse
    public let challenge: ChallengeResponse
}
