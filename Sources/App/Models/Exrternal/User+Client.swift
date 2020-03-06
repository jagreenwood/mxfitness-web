//
//  File.swift
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
    public let id: String
    public let name: String
    public let email: String
//    public let workouts: [WorkoutResponse]
}
