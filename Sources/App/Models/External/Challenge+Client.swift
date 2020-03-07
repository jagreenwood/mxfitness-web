//
//  File.swift
//  
//
//  Created by Jeremy Greenwood on 3/7/20.
//

import Foundation

public struct ChallengeCreate: Codable, Equatable {
    private enum CodingKeys: String, CodingKey {
        case name
        case startDate = "start_date"
        case endDate = "end_date"
    }

    public let name: String
    public let startDate: Date
    public let endDate: Date
}

public struct ChallengeResponse: Codable, Equatable {
    private enum CodingKeys: String, CodingKey {
        case name, users
        case startDate = "start_date"
        case endDate = "end_date"
    }

    public let id: String
    public let name: String
    public let startDate: Date
    public let endDate: Date
    public let users: [UserResponse]
}
