//
//  File.swift
//  
//
//  Created by Jeremy Greenwood on 3/8/20.
//

import Fluent
import Vapor
import Leaf
import Model

struct WorkoutController { }

/// Session Calls
extension WorkoutController {
    static func challengeWorkoutsView(_ request: Request) throws -> EventLoopFuture<View> {
        _ = try request.auth.require(User.self)

        return ChallengeController.challenge(for: request.parameters.get("id")!, request: request)
            .flatMapThrowing { try $0.workouts.responses(request) }.flatMap { $0 }.flatMap {
                request.view.render("challenge_workouts", [Arguments.workouts: $0])
        }
    }

    static func sessionCreate(_ request: Request) throws -> EventLoopFuture<Response> {
        try createWorkout(request).map {
            request.redirect(to: "/user/\($0.$user.id)")
        }
    }
}

/// API calls
extension WorkoutController {
    static func create(_ request: Request) throws -> EventLoopFuture<WorkoutResponse> {
        try createWorkout(request).flatMapThrowing {
            try $0.response(request)
        }.flatMap { $0 }
    }
}

private extension WorkoutController {
    static func createWorkout(_ request: Request) throws -> EventLoopFuture<Workout> {
        let user = try request.auth.require(User.self)
        let workoutCreate = try request.content.decode(WorkoutCreate.self)

        let promise = request.eventLoop.makePromise(of: Workout.self)

        DispatchQueue.global().async {
            do {
                try user.$challenge.load(on: request.db).wait()

                guard let challenge = user.challenge else {
                    throw Abort(.custom(code: 500, reasonPhrase: "User has not joined a challenge"))
                }

                let workout = try Workout(duration: workoutCreate.duration,
                                          date: workoutCreate.date.date(),
                                          type: workoutCreate.type,
                                          userID: user.requireID(),
                                          challengeID: challenge.requireID())

                try workout.save(on: request.db).wait()
                try workout.$user.load(on: request.db).wait()
                promise.succeed(workout)
            } catch {
                promise.fail(error)
            }
        }

        return promise.futureResult.map { $0 }
    }
}
