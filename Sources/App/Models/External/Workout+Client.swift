//
//  Workout+Client.swift
//  
//
//  Created by Jeremy Greenwood on 3/7/20.
//

import Foundation

public struct WorkoutCreate: Codable {
    private enum CodingKeys: String, CodingKey {
        case duration, type
    }

    public let duration: TimeInterval
    public let type: String
}

public struct WorkoutResponse: Codable, Equatable {
    private enum CodingKeys: String, CodingKey {
        case id, duration, type, user
    }

    public let id: String
    public let duration: TimeInterval
    public let type: String
    public let user: UserResponse
}
