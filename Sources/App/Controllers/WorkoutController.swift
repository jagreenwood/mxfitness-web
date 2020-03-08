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
}
