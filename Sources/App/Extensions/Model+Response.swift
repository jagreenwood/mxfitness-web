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
            .flatMapThrowing {
                try ChallengeResponse(id: self.requireID().uuidString,
                                      name: self.name,
                                      startDate: self.startDate,
                                      endDate: self.endDate,
                                      users: self.users.baseResponses())
        }
    }
}

extension Array where Element == User {
    func baseResponses() throws -> [BaseUserResponse] {
        return try map { try $0.baseResponse() }
    }

    func responses(_ request: Request) throws -> EventLoopFuture<[UserResponse]> {
        return try map { try $0.response(request) }.flatten(on: request.eventLoop)
    }
}

extension User {
    var userAvatar: URL? {
        guard let md5 = email.md5, let avatar = URL(string: "https://www.gravatar.com/avatar/\(md5)?s=200") else {
            return nil
        }

        return avatar
    }

    func baseResponse() throws -> BaseUserResponse {
        guard let avatar = userAvatar else {
            throw Abort(.internalServerError)
        }
        
        return try BaseUserResponse(id: requireID().uuidString, name: name, avatar: avatar, role: role.rawValue)
    }

    func response(_ request: Request) throws -> EventLoopFuture<UserResponse> {
        guard let avatar = userAvatar else {
            throw Abort(.internalServerError)
        }

        return $workouts.load(on: request.db)
            .flatMapThrowing { try self.workouts.responses(request) }
            .flatMap { $0 }
            .flatMapThrowing { workoutResponses in
                try UserResponse(id: self.requireID().uuidString,
                                 name: self.name,
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
            .flatMapThrowing {
                try WorkoutResponse(id: self.requireID().uuidString,
                                    duration: self.duration,
                                    type: self.type,
                                    user: self.user.baseResponse())
        }
    }
}

extension UserToken {
    func response() -> TokenResponse {
        TokenResponse(token: value)
    }
}
