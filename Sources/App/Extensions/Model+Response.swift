//
//  File.swift
//  
//
//  Created by Jeremy Greenwood on 3/7/20.
//

import Foundation
import Vapor
import Model

extension Array where Element == Challenge {
    func responses(_ request: Request) throws -> EventLoopFuture<[ChallengeResponse]> {
        return try map { try $0.response(request) }.flatten(on: request.eventLoop)
    }
}

extension Challenge {
    func response(_ request: Request) throws -> EventLoopFuture<ChallengeResponse> {
        $users.load(on: request.db)
            .flatMapThrowing { try self.users.responses(request) }.flatMap { $0 }
            .flatMapThrowing {
                try ChallengeResponse(id: self.requireID().uuidString, name: self.name, startDate: self.startDate, endDate: self.endDate, users: $0)
        }
    }
}

extension Array where Element == User {
    func responses(_ request: Request) throws -> EventLoopFuture<[UserResponse]> {
        return try map { try $0.response(request) }.flatten(on: request.eventLoop)
    }
}

extension User {
    func response(_ request: Request) throws -> EventLoopFuture<UserResponse> {
        guard let md5 = email.md5, let avatar = URL(string: "https://www.gravatar.com/avatar/\(md5)?s=200") else {
            throw Abort(.internalServerError)
        }

        return $workouts.load(on: request.db)
            .flatMapThrowing { try self.workouts.responses(request) }
            .flatMap { $0 }
            .flatMapThrowing { workoutResponses in
                try UserResponse(id: self.requireID().uuidString,
                                 name: self.name,
                                 email: self.email,
                                 avatar: avatar,
                                 role: self.role.rawValue,
                                 workouts: workoutResponses,
                                 totalWorkoutCount: self.workouts.count,
                                 totalWorkoutDuration: self.workouts.totalDuration)
        }
    }
}

extension Array where Element == Workout {
    func responses(_ request: Request) throws -> EventLoopFuture<[WorkoutResponse]> {
        return try map { try $0.response(request) }.flatten(on: request.eventLoop)
    }
}

extension Workout {
    func response(_ request: Request) throws -> EventLoopFuture<WorkoutResponse> {
        $user.load(on: request.db)
            .flatMapThrowing { try self.user.response(request) }.flatMap { $0 }
            .flatMapThrowing {
                try WorkoutResponse(id: self.requireID().uuidString,
                                    duration: self.duration,
                                    type: self.type,
                                    user: $0)
        }
    }
}

extension UserToken {
    func response() -> TokenResponse {
        TokenResponse(token: value)
    }
}
