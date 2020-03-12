//
//  File.swift
//  
//
//  Created by Jeremy Greenwood on 3/8/20.
//

import Fluent
import Vapor
import Leaf

struct WorkoutController { }

/// Session Calls
extension WorkoutController {
    static func challengeWorkoutsView(_ request: Request) throws -> EventLoopFuture<View> {
        _ = try request.auth.require(User.self)

        return ChallengeController.challenge(for: request.parameters.get("id")!, request: request)
            .flatMapThrowing { try $0.workouts.responses() }.flatMap {
                request.view.render("challenge_workouts", [Arguments.workouts: $0])
        }
    }

    static func sessionCreate(_ request: Request) throws -> EventLoopFuture<Response> {
        let user = try request.auth.require(User.self)
        let create = try request.content.decode(WorkoutCreate.self)

        return user.$challenge.load(on: request.db).flatMapThrowing { (Void) -> Workout in
            guard let challenge = user.challenge else {
                throw Abort(.custom(code: 500, reasonPhrase: "User has not joined a challenge"))
            }

            return try Workout(duration: create.duration, type: create.type, userID: user.requireID(), challengeID: challenge.requireID())
        }.flatMapThrowing { foo in
            try user.requireID()
        }.map {
            request.redirect(to: "/users/\($0)/workouts")
        }
    }
}
